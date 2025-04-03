#!/usr/bin/python3
import argparse
import glob
import os
from collections import UserDict

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

    def __init__(self, args):
        self.args = args

    @staticmethod
    def get_meta(csv_path):
        path = os.path.join(os.path.dirname(csv_path), 'meta.yaml')
        return yaml.safe_load(open(path, encoding='utf-8'))

    def get_output_dir(self, name):
        dpath = os.path.join(self.args.output_path, 'graphs',
                             name.partition('_')[0])
        if not os.path.exists(dpath):
            os.makedirs(dpath)

        return dpath

    @property
    def data_files(self):
        return glob.glob(os.path.join(self.args.data_path, '*/*/*.csv'))

    def run(self):
        for path in self.data_files:
            name = os.path.basename(path).partition('.')[0]
            print(f"Plotting data for {name} ({path})")
            self.stacked(name, pd.read_csv(path), self.get_meta(path))

    @staticmethod
    def x_data(csv):
        data = csv
        try:
            a = np.datetime64(f"{data['datetime'].values[0]}:00")
            b = np.datetime64(f"{data['datetime'].values[-1]}:00")
        except ValueError:
            a = np.datetime64(f"2025-01-01T{data['datetime'].values[0]}:00")
            b = np.datetime64(f"2025-01-01T{data['datetime'].values[-1]}:00")

        b += np.timedelta64(10, 'm')
        return np.arange(a, b, np.timedelta64(10, 'm'))

    def stacked(self, name, csv, meta, use_bar=False):
        output = os.path.join(self.get_output_dir(name), f"{name}.png")
        if os.path.exists(output) and not self.args.overwrite:
            print(f"INFO: {output} already exists - use --overwrite to "
                  "recreate")
            return

        stacked = []
        labels = []
        _, ax = plt.subplots()
        for key in csv:
            if key == 'datetime':
                continue

            labels.append(key)
            stacked.append(csv[key])

        if use_bar:
            width = 0.005
            bottom = np.zeros(len(csv['datetime']))
            for label, item in zip(labels, stacked):
                ax.bar(self.x_data(csv), item, width, label=label,
                       bottom=bottom)
                bottom += csv[label]
        else:
            ax.stackplot(self.x_data(csv), stacked, labels=labels)

        ax.xaxis_date()
        plt.xlabel(meta['xlabel'])
        plt.ylabel(meta['ylabel'])
        plt.legend()
        plt.subplots_adjust(**PlotSettings())
        plt.tight_layout()
        plt.gcf().set_size_inches(self.PLOT_SIZE_X, self.PLOT_SIZE_Y)
        plt.savefig(output, dpi=100,
                    bbox_inches='tight',
                    pad_inches=self.PLOT_PAD_INCHES)
        plt.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--overwrite', action='store_true', default=False)
    parser.add_argument('--output-path', type=str, required=True)
    parser.add_argument('--data-path', type=str, required=True)
    parser.add_argument('--host', type=str, required=False)
    PLOT(parser.parse_args()).run()
