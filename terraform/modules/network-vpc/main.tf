# ── VPC ────────────────────────────────────────────────────────────────────────

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

# ── Internet Gateway ──────────────────────────────────────────────────────────

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

# ── Public Subnets ─────────────────────────────────────────────────────────────
# NAT Gateway와 Internet Gateway 경로를 가지는 Public Subnet이다.

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-${count.index + 1}"
    Tier = "public"
    Role = "nat"
  })
}

# ── TGW Attachment Subnets ─────────────────────────────────────────────────────
# Transit Gateway Attachment를 배치할 전용 Subnet이다.
# 이후 spoke VPC의 outbound 트래픽이 TGW → Network VPC → NAT Gateway 경로로 나가게 된다.

resource "aws_subnet" "tgw_attachment" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.tgw_attachment_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tgw-attachment-${count.index + 1}"
    Tier = "private"
    Role = "tgw-attachment"
  })
}

# ── Public Route Table ─────────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_default_to_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ── Centralized NAT Gateway ────────────────────────────────────────────────────
# 비용 절감을 위해 기본값은 단일 NAT Gateway 구성을 사용한다.
# 고가용성이 필요한 경우 추후 AZ별 NAT Gateway로 확장할 수 있다.

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "central" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-central-nat"
  })

  depends_on = [aws_internet_gateway.this]
}

# ── TGW Attachment Route Table ─────────────────────────────────────────────────
# TGW Attachment Subnet에 연결되는 Route Table이다.
# 기본 인터넷 방향 트래픽은 Centralized NAT Gateway로 보낸다.
# 실제 App/Data VPC와의 TGW 라우팅은 Transit Gateway 이슈에서 추가한다.

resource "aws_route_table" "tgw_attachment" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tgw-attachment-rt"
  })
}

resource "aws_route" "tgw_attachment_default_to_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.tgw_attachment.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.central[0].id
}

resource "aws_route_table_association" "tgw_attachment" {
  count = length(aws_subnet.tgw_attachment)

  subnet_id      = aws_subnet.tgw_attachment[count.index].id
  route_table_id = aws_route_table.tgw_attachment.id
}