#!/usr/bin/env python

import os
import json
import numpy as np

from datetime import datetime
import matplotlib.pyplot as plt

# Helper Functions

def make_content_arrays(content_arrays, contents, date, key=None):
    """Converts to a format that can be easily plotted. 
       Add contents on a given date to content_arrays. 
       content_arrays will be similar to content_arrays, but its leafs
       will be lists of tuples, consisting of the date and values.
    """
    
    # Most of the data is organized in dicts.
    if isinstance(contents, dict):
        for key, val in contents.items():
            if key not in content_arrays:
                content_arrays[key] = {}
            make_content_arrays(content_arrays[key], val, date, key)
            
    # Some of the data appears in lists. The items in the lists often have
    # a 'label'. Handle this special case, and if a label is not found just
    # use the index.
    elif isinstance(contents, list):
        for i, el in enumerate(contents):
            if 'label' in el:
                new_key = key + ": " + el['label']
            else:
                new_key = key + ": " + str(i)
            if new_key not in content_arrays:
                content_arrays[new_key] = {}
            make_content_arrays(content_arrays[new_key], el, date)
            
    # Append the entry
    else:
        if key not in content_arrays:
            content_arrays[key] = []
        content_arrays[key].append((date, contents))


def plot_content_arrays(content_arrays, title_append="", show=False, prefix=None):
    for key, val in content_arrays.items():
        if isinstance(val, dict):
            if prefix != None:
                prefix = ("%s-%s" % (prefix, key)).lower()
            plot_content_arrays(val, title_append = title_append + " " + key, prefix=prefix)
        else:
            try:
                dates, values = zip(*val)

                # Don't make a plot of all empty values.
                if not any(values):
                    continue

                # Can't plot strings, so skip them.
                if any([isinstance(v, str) for v in values]):
                    continue

                plt.figure(figsize=(15,5))
                plt.plot(dates, values)
                plt.title(title_append)

                # Does the user want to show the plot?
                if show == True:
                    plt.show()

                # Does the user want to save it?
                if prefix != None:
                    save_as = prefix + '.png'
                    print('Saving figure to %s' % save_as)
                    plt.savefig(save_as)

                plt.close()
            except ValueError as e:
                print(values)
                print(e)


def date_to_npdate(date):
    day, time, zone = date.split()
    return day+"T"+time


def process_arrays(data):
    dates = data['dates']

    ## Use a different formatting for the dates.
    npdates = np.array(list(map(date_to_npdate, dates)), dtype='datetime64').astype(datetime)

    content_arrays = {}
    for i, date in enumerate(npdates):
        content_at_step = json.loads(data['content'][i])
        make_content_arrays(content_arrays, content_at_step, date)
    return content_arrays


def main():

    ## These do not include temporal data to plot
    EXCLUDE = set(["task-python.json", "task-users.json", "task-system.json"])

    # Create an image folder
    if not os.path.exists('img'):
        os.mkdir('img')

    # Find relevant files in $PWD, exclude non temporal ones
    json_files = set([f for f in os.listdir(".") if f[-len('.json'):] == ".json"]) - EXCLUDE

    for json_file in json_files:
        filename, ext = os.path.splitext(os.path.basename(json_file))
        print('file: %s' % json_file)
        with open(json_file) as f:
            data = json.load(f)
        arrays = process_arrays(data)
        plot_content_arrays(arrays, prefix=os.path.join('img', filename))


if __name__ == '__main__':
    main()
