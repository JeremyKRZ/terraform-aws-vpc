### Module Main

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name        = var.vpc-name
    Environment = var.env
    Owner       = var.owner
  }
}

resource "aws_subnet" "public" {
  //Le for each prend un MAP
  for_each                = var.zones
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}${each.key}"

  //CIDR Blocks of /20 will be generated
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = {
    Name        = "${var.vpc-name}-public-${var.aws_region}${each.key}"
    Environment = var.env
    Owner       = var.owner
  }
}

resource "aws_subnet" "private" {
  //Le for each prend un MAP
  for_each                = var.zones
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_region}${each.key}"

  //CIDR Blocks of /20 will be generated
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, 15 - each.value)

  tags = {
    Name        = "${var.vpc-name}-private-${var.aws_region}${each.key}"
    Environment = var.env
    Owner       = var.owner
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.vpc-name}-igw"
    Environment = var.env
    Owner       = var.owner
  }
}

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow inboud traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "sg"
    Environment = var.env
    Owner       = var.owner
  }
}

resource "aws_security_group_rule" "allow_all_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65365
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "allow_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "jeremykey"
  public_key = file("./aws.pub")
}


resource "aws_instance" "nat" {
  for_each               = var.zones
  ami                    = data.aws_ami.ami-nat.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  subnet_id              = aws_subnet.public[each.key].id
  source_dest_check = false
  key_name = aws_key_pair.deployer.key_name
  tags = {
    Name        = "${var.vpc-name}-nat-${var.aws_region}${each.key}"
    Environment = var.env
    Owner       = var.owner
  }
}

resource "aws_eip" "nat_eip" {
  for_each = var.zones
  vpc      = true
}

resource "aws_eip_association" "eip_assoc" {
  for_each      = var.zones
  instance_id   = aws_instance.nat[each.key].id
  allocation_id = aws_eip.nat_eip[each.key].id
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.vpc-name}-public-rt"
    Environment = var.env
    Owner       = var.owner
  }
}

resource "aws_route_table" "private-rt" {
  for_each = var.zones
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.vpc-name}-private-rt"
    Environment = var.env
    Owner       = var.owner
  }
}

resource "aws_route" "public_internet-gateway" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id            = aws_internet_gateway.gw.id
}

resource "aws_route" "private_nat_gateway" {
  for_each               = var.zones
  route_table_id         = aws_route_table.private-rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = aws_instance.nat[each.key].id
}

resource "aws_route_table_association" "public-rta" {
  for_each = var.zones
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-rta" {
  for_each = var.zones
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private-rt[each.key].id
}
