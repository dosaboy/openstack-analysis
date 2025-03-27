#!/usr/bin/python3
import os
import sys
import datetime
from collections import UserDict
from functools import cached_property

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import yaml


class PlotSettings(UserDict):
    """ Matplotlib graph settings. """
    def __init__(self):
        init = {
            'left': 0.04,
            'right': 0.96,
            'top': 0.96,
            'bottom': 0.04,
        }
        super().__init__(init)


class PLOT():
    """
    Plot graph from csv data.
    """
    PLOT_SIZE_X = 23
    PLOT_SIZE_Y = 12
    PLOT_PAD_INCHES = 0.25

    @cached_property
    def meta(self):
        path = os.path.join(os.path.dirname(sys.argv[1]), 'meta.yaml')
        return yaml.safe_load(open(path, encoding='utf-8'))

    @property
    def output(self):
        return os.path.join(self.output_dir, f"{self.name}.png")

    @property
    def path(self):
        return sys.argv[1]

    @property
    def name(self):
        return os.path.basename(self.path).partition('.')[0]

    @property
    def output_dir(self):
        dpath = os.environ['OUTPUT_PATH']
        dpath = os.path.join(dpath, 'graphs', self.name.partition('_')[0])
        if not os.path.exists(dpath):
            os.makedirs(dpath)

        return dpath

    @cached_property
    def csv(self):
        return pd.read_csv(self.path)

    @property
    def force(self):
        return os.environ.get('OVERWRITE_CSV') == "true"

    @property
    def x_data(self):
        data = self.csv
        try:
            a = np.datetime64(f"{data['datetime'].values[0]}:00")
            b = np.datetime64(f"{data['datetime'].values[-1]}:00")
        except ValueError:
            a = np.datetime64(f"2025-01-01T{data['datetime'].values[0]}:00")
            b = np.datetime64(f"2025-01-01T{data['datetime'].values[-1]}:00")

        b += np.timedelta64(10, 'm')
        return np.arange(a, b, np.timedelta64(10, 'm'))

    def stacked(self, use_bar=False):
        print(f"Plotting data for {self.name} ({self.path})")
        if os.path.exists(self.output) and not self.force:
            print(f"INFO: {self.output} already exists - use --overwrite to "
                  "recreate")
            return

        stacked = []
        labels = []
        _, ax = plt.subplots()
        for key in self.csv:
            if key == 'datetime':
                continue

            labels.append(key)
            stacked.append(self.csv[key])

        if use_bar:
            width = 0.005
            bottom = np.zeros(len(self.csv['datetime']))
            for label, item in zip(labels, stacked):
                ax.bar(self.x_data, item, width, label=label,
                       bottom=bottom)
                bottom += self.csv[label]
        else:
            ax.stackplot(self.x_data, stacked, labels=labels)

        ax.xaxis_date()
        plt.xlabel(self.meta['xlabel'])
        plt.ylabel(self.meta['ylabel'])
        plt.legend()
        plt.subplots_adjust(**PlotSettings())
        plt.tight_layout()
        plt.gcf().set_size_inches(self.PLOT_SIZE_X, self.PLOT_SIZE_Y)
        plt.savefig(self.output, dpi=100,
                    bbox_inches='tight',
                    pad_inches=self.PLOT_PAD_INCHES)

    @staticmethod
    def test():
        # data from https://allisonhorst.github.io/palmerpenguins/

        species = (
            "Adelie\n $\\mu=$3700.66g",
            "Chinstrap\n $\\mu=$3733.09g",
            "Gentoo\n $\\mu=5076.02g$",
        )
        weight_counts = {
            "Below": np.array([70, 31, 58]),
            "Above": np.array([82, 37, 66]),
        }
        width = 0.5

        _, ax = plt.subplots()
        bottom = np.zeros(3)

        for boolean, weight_count in weight_counts.items():
            ax.bar(species, weight_count, width, label=boolean, bottom=bottom)
            bottom += weight_count

        ax.set_title("Number of penguins with above average body mass")
        ax.legend(loc="upper right")

        plt.show()

    def test2(self):
        # https://paste.ubuntu.com/p/pmWQXCDk7w/plain/
        df = self.csv

        x = []
        for d in df['datetime']:
            try:
                x.append(datetime.datetime.strptime(d, "%H:%M"))
            except ValueError:
                x.append(datetime.datetime.strptime(d, '%Y-%m-%d:%H:%M'))

        print(type(df['datetime']))
        df['datetime'] = pd.core.series.Series(x)

        # Plot the stacked bar chart
        plt.figure(figsize=(12, 6))
        df.set_index('datetime').plot(kind='bar', stacked=True,
                                      figsize=(12, 6))
        plt.xlabel('Time')
        plt.ylabel('Value')
        plt.title('Stacked Bar Chart of CSV Data')
        plt.legend(title='Category', bbox_to_anchor=(1.05, 1),
                   loc='upper left')
        plt.xticks(rotation=45)
        plt.tight_layout()

        # Show the plot
        plt.show()


if __name__ == "__main__":
    PLOT().stacked()
    # PLOT().test2()
