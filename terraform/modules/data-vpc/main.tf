# ── VPC ────────────────────────────────────────────────────────────────────────
# Data VPC는 RDS, Redis, OpenSearch 같은 데이터 계층 리소스를 배치한다.
# 외부 인터넷 직접 접근을 차단하기 위해 Internet Gateway를 생성하지 않는다.

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

# ── Private DB Subnets ─────────────────────────────────────────────────────────

resource "aws_subnet" "private_db" {
  count = length(var.private_db_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_db_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-db-${count.index + 1}"
    Tier = "private"
    Role = "db"
  })
}

# ── Private Cache Subnets ──────────────────────────────────────────────────────

resource "aws_subnet" "private_cache" {
  count = length(var.private_cache_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_cache_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-cache-${count.index + 1}"
    Tier = "private"
    Role = "cache"
  })
}

# ── Private Search Subnets ─────────────────────────────────────────────────────

resource "aws_subnet" "private_search" {
  count = length(var.private_search_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_search_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-search-${count.index + 1}"
    Tier = "private"
    Role = "search"
  })
}

# ── TGW Attachment Subnets ─────────────────────────────────────────────────────
# Transit Gateway Attachment 전용 Subnet이다.
# Data VPC는 IGW 없이 TGW를 통해 App VPC에서만 접근되도록 구성한다.

resource "aws_subnet" "tgw_attachment" {
  count = length(var.tgw_attachment_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.tgw_attachment_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tgw-attachment-${count.index + 1}"
    Tier = "private"
    Role = "tgw-attachment"
  })
}

# ── Transit Gateway Attachment ─────────────────────────────────────────────────

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  count = var.transit_gateway_id != "" ? 1 : 0

  subnet_ids         = aws_subnet.tgw_attachment[*].id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tgw-attachment"
  })
}

# ── Private Route Table ────────────────────────────────────────────────────────
# Data VPC에는 Internet Gateway를 생성하지 않는다.
# App VPC CIDR로 향하는 응답 트래픽만 TGW로 보낸다.

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-rt"
  })
}

resource "aws_route" "private_app_vpc_to_tgw" {
  count = var.transit_gateway_id != "" ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.app_vpc_cidr
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}

resource "aws_route_table_association" "private_db" {
  count = length(aws_subnet.private_db)

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_cache" {
  count = length(aws_subnet.private_cache)

  subnet_id      = aws_subnet.private_cache[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_search" {
  count = length(aws_subnet.private_search)

  subnet_id      = aws_subnet.private_search[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "tgw_attachment" {
  count = length(aws_subnet.tgw_attachment)

  subnet_id      = aws_subnet.tgw_attachment[count.index].id
  route_table_id = aws_route_table.private.id
}
