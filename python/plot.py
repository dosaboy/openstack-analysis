#!/usr/bin/python3
import argparse
import glob
import os
import sys
from collections import UserDict

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import yaml
from jinja2 import FileSystemLoader, Environment


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

    @staticmethod
    def get_graph_name(path):
        return os.path.basename(path).partition('.')[0]

    @staticmethod
    def get_script_and_hostname(path):
        host, _, script = os.path.basename(path).partition('_')
        return host, script

    def run(self):
        for path in self.data_files:
            if self.args.host:
                host, _ = self.get_script_and_hostname(path)
                if host not in self.args.host:
                    continue

            self.stacked(path)

        for template in ['summary_by_agent.html.j2',
                         'summary_by_host.html.j2']:
            path = os.path.join(self.args.output_path,
                                template.partition('.j2')[0])
            print(f"INFO: saving html page of all graphs to {path}")
            with open(path, 'w', encoding='utf-8') as fd:
                fd.write(self.render(template))

    @property
    def script_root(self):
        return os.path.dirname(sys.argv[0])

    def get_renderer_context(self):
        context = {'agents': {}, 'hosts': {}}
        for path in self.data_files:
            meta = self.get_meta(path)
            agent = meta.get('agent', 'unknown-agent')
            if agent not in context['agents']:
                context['agents'][agent] = {}

            host, script = self.get_script_and_hostname(path)
            if host not in context['hosts']:
                context['hosts'][host] = {}

            script = script.partition('.csv')[0]
            if script not in context['agents'][agent]:
                context['agents'][agent][script] = []

            if script not in context['hosts'][host]:
                context['hosts'][host][script] = []

            path = self.get_output_path(self.get_graph_name(path))
            path = path.partition('/')[2]
            context['agents'][agent][script].append(
                {'path': path, 'host': host})

            context['hosts'][host][script].append(
                {'path': path, 'agent': agent})

        return context

    def render(self, template):
        # jinja 2.10.x really needs this to be a str and e.g. not a PosixPath
        templates_dir = str(self.script_root)
        if not os.path.isdir(templates_dir):
            raise FileNotFoundError(
                f"jinja templates directory not found: '{templates_dir}'")

        env = Environment(loader=FileSystemLoader(templates_dir))
        template = env.get_template(template)
        return template.render(self.get_renderer_context())

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

    def get_output_path(self, name):
        return os.path.join(self.get_output_dir(name), f"{name}.png")

    def stacked(self, path):
        name = self.get_graph_name(path)
        print(f"Plotting data for {name} ({path})")
        csv = pd.read_csv(path)
        meta = self.get_meta(path)
        use_bar = meta.get('type') == 'bar_stacked'

        output = self.get_output_path(name)
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
        plt.xlabel(meta['xlabel'], fontsize=20)
        plt.ylabel(meta['ylabel'], fontsize=20)
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
    parser.add_argument('--host', action='append', required=False)
    PLOT(parser.parse_args()).run()
