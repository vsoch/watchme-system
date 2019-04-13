workflow "Update Notebook on Push" {
  on = "push"
  resolves = "Deploy to GitHub Pages"
}

action "cpu" {
  uses = "actions/action-builder/shell@master"
  runs = "cp"
  args = ["task-cpu/vanessa-thinkpad-t460s_vanessa.jso data/task-cpu.json"]
}

action "system" {
  uses = "actions/action-builder/shell@master"
  runs = "cp"
  args = ["task-system/vanessa-thinkpad-t460s_vanessa.jso data/task-system.json"]
}

action "sensors" {
  uses = "actions/action-builder/shell@master"
  runs = "cp"
  args = ["task-sensors/vanessa-thinkpad-t460s_vanessa.jso data/task-sensors.json"]
}

action "network" {
  uses = "actions/action-builder/shell@master"
  runs = "cp"
  args = ["task-network/vanessa-thinkpad-t460s_vanessa.jso data/task-network.json"]
}


action "memory" {
  uses = "actions/action-builder/shell@master"
  runs = "cp"
  args = ["task-memory/vanessa-thinkpad-t460s_vanessa.jso data/task-memory.json"]
}

action "List" {
  needs = ['memory', 'network', 'system', 'sensors', 'cpu']
  uses = "actions/action-builder/shell@master"
  runs = "ls"
  args = "data/"
}

action "Generate" {
  needs = ['memory', 'network', 'system', 'sensors', 'cpu']
  uses = "docker://faizanbashir/python-datascience:3.6"
  args = "cd data && python3 generate.py"
}

action "Deploy to GitHub Pages" {
  uses = "maxheld83/ghpages@v0.2.1"
  env = {
    BUILD_DIR = "data/img"
  }
  secrets = ["GH_PAT"]
}
