[
  {
    "name": "${app_name}",
    "image": "${aws_ecr_repository}:${tag}@${digest}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${region}",
        "awslogs-group": "/ecs/${app_name}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${host_port},
        "protocol": "tcp"
      }
    ],
    "cpu": 2,
    "environment": [
      {
        "name": "PORT",
        "value": "${host_port}"
      }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      }
    ],
    "mountPoints": [],
    "memory": 512,
    "volumesFrom": []
  }
]
