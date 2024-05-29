 #aws_vpc.main-vpc.id

 resource "aws_security_group" "security-group" {
    vpc_id = var.vpc_id
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        prefix_list_ids =[]
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.app_name}-sg"
    }
 }

#Role para o cluster
 resource "aws_iam_role" "cluster-iam-role" {
   name = "${var.app_name}-${var.cluster_name}-role"
   assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            },
        ]
  })
 }

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
     role = aws_iam_role.cluster-iam-role.name
     policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
     role = aws_iam_role.cluster-iam-role.name
     policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_cloudwatch_log_group" "log" {
    name = "/aws/eks/${var.app_name}-${var.cluster_name}/cluster"
    retention_in_days = var.log_retention_day
}

#aws_subnet.subnets[*].id
resource "aws_eks_cluster" "eks-cluster" {
    name = "${var.app_name}-${var.cluster_name}"
    role_arn = aws_iam_role.cluster-iam-role.arn
    enabled_cluster_log_types = ["api", "audit"]
    vpc_config {
      subnet_ids = var.subnets_ids
      security_group_ids = [aws_security_group.security-group.id]
    }
    depends_on = [ 
        aws_cloudwatch_log_group.log, 
        aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy, 
        aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController 
    ]
}

##nodes
#Role para os nodes de um cluster
resource "aws_iam_role" "node-iam-role" {
   name = "${var.app_name}-${var.cluster_name}-node-role"
   assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            },
        ]
  })
}

#Acessos
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
     role = aws_iam_role.node-iam-role.name
     policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

#Permitir comunicação entre os nodes e etc
resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
     role = aws_iam_role.node-iam-role.name
     policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

#Permitir para acessar o container registry para acesso as imagens docker registradas
resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
     role = aws_iam_role.node-iam-role.name
     policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#
resource "aws_eks_node_group" "node-1" {
    cluster_name    = aws_eks_cluster.eks-cluster.name
    node_group_name = "node-1"
    node_role_arn   = aws_iam_role.node-iam-role.arn
    subnet_ids      = var.subnets_ids
    instance_types  = ["t2.micro"]
    scaling_config {
        desired_size = var.desired_size
        max_size     = var.max_size
        min_size     = var.min_size
    }

    depends_on = [
        aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
    ]
}

# resource "aws_eks_node_group" "node-2" {
#     cluster_name    = aws_eks_cluster.eks-cluster.name
#     node_group_name = "node-2"
#     node_role_arn   = aws_iam_role.node-iam-role.arn
#     subnet_ids      = var.subnets_ids
#     instance_types  = ["t2.micro"]
#     scaling_config {
#         desired_size = var.desired_size
#         max_size     = var.max_size
#         min_size     = var.min_size
#     }

#     depends_on = [
#         aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
#         aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
#         aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
#     ]
# }