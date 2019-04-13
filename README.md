# System Watcher

This is an example watcher to record system metrics, ranging from memory, to
networking, python interpreter, sensors (battery, fans, temperature), and
users. You can explore each of the folders to see the (json) data exported, 
on an hourly bases, and automated with cron, from my system:

 - [task-cpu](task-cpu)
 - [task-memory](task-memory)
 - [task-network](task-network)
 - [task-python](task-python)
 - [task-sensors](task-sensors)
 - [task-system](task-system)
 - [task-users](task-users)

You can also see an example of using Local hooks and containers to generate 
a nice visual.

 - [Hooks](#hooks)


### What is WatchMe?

WatchMe is a [tool for reproducible monitoring](https://vsoch.github.io/watchme).
This means that you can create one or more tasks to monitor web or system resources,
and collection version controlled results (git) at a regular interval (cron). 
For more details, see the [documentation base](https://vsoch.github.io/watchme)


## Clone

To clone this repository (and start with the watchers here), you can
first install watchme:

```bash
$ pip install watchme[psutils]
```

and then get the repository:

```bash
              # repository                                # watcher name
$ watchme get https://www.github.com/vsoch/watchme-system system
Added watcher watchme-system
```

Conflrm that it was added:

```bash
$ watchme list
air-quality
system
```

This will install the data to your $HOME/.watchme folder by default, unless
you've exported another `WATCHME_BASE_DIR`. Before you run the task, 
take a look at the data that has already been collected. For eack task
folder, you can export changes for a file like this 

```bash
#              <watcher> <task>    <filename>
$ watchme export system task-users vanessa-thinkpad-t460s_vanessa.json
```

If you expect the data in the files to be json (and want to parse it into the result)
then do this:

```bash
$ watchme export system task-users vanessa-thinkpad-t460s_vanessa.json --json
```

There is a `TIMESTAMP` file that is kept in each folder as a record of when 
it was last run. You can then run the task manually in test mode to see output

```bash
$ watchme run system --test
```

But likely you want to activate and schedule the task to run.


### Schedule the Task

Instead of a manual run, you likely want to run the task and look for changes 
over time. You can do that like this:

```bash
$ watchme schedule system @hourly
```

And then check that an entry has been added to crontab:

```bash
$ crontab -l
@hourly watchme run system # watchme-system
```

Finally, ensure that the watcher is active:

```bash
$ watchme activate system
```

## Creation

If you want to reproduce creating this watcher, it looks something like this:

Install Watchme

```bash
$ pip install watchme[psutils]
```

Initialize the base folder at $HOME/.watchme

```bash
$ watchme init
```

Create the system watcher:

```bash
$ watchme create system
```

And then install each of the tasks as follows:

```bash
watchme add task-cpu func@cpu_task active@true type@psutils
watchme add task-memory func@memory_task active@true type@psutils
watchme add task-network func@net_task skip@net_connections,net_if_address active@true type@psutils
watchme add task-python func@python_task active@true type@psutils
watchme add task-sensors func@sensors_task active@true type@psutils
watchme add task-system func@system_task active@true type@psutils
watchme add task-users func@users_task active@true type@psutils
```

You can easily export a current configuration file (how I produced the commands above).


```bash
$ watchme inspect system --add-command
```

Note that for the psutils watcher, the export above would include file_name, but
you don't need to (it's added automatically with your host and username.

## Export Data

As an example, I created this watcher with the commands above, and 
decided to export data (after about a day and a half) and do an analysis to
show change in metrics about my computer over time. This simple example will serve
to show that WatchMe is useful to answer research questions, as it collected my data
for me without me needing to do anything. Here are the commands to export each of the data
files:

```bash
$ mkdir -p data
$ for task in cpu memory network python sensors system users
do
    watchme export system task-$task --out data/task-$task.json vanessa-thinkpad-t460s_vanessa.json --json
done
```

## Hooks

If you want to deploy a set of images from your watcher to GitHub pages, that is very
easy to do! Just copy the [hooks/pre-push](hooks/pre-push) hook into your .git/hooks
folder, like this:

```bash
$ cp hooks/pre-push .git/hooks
```

And you are good to go! The hook will pull a container to do the generation, if it
doens't exist already.
