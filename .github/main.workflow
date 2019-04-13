workflow "Update Notebook on Push" {
  on = "push"
  resolves = "Generate and Deploy"
}

action "Generate and Deploy" {
  uses = "docker://faizanbashir/python-datascience:3.6"
  runs = "/bin/bash"
  args = "/github/workspace/data/deploy.sh"
}
