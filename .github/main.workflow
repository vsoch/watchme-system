workflow "Update Github Pages on Push" {
  on = "push"
  resolves = "Generate and Deploy"
}

action "Generate and Deploy" {
  uses = "docker://faizanbashir/python-datascience:3.6"
  runs = "/bin/bash"
  secrets = ["GITHUB_TOKEN"]
  args = "/github/workspace/data/deploy.sh"
}
