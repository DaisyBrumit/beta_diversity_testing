import seaborn as sns
import matplotlib as plt

def plot_pcAxes(simulation_metrics):
    category = 'delivery'
    pal_use = {'Vaginal': '#377eb8',
               'Cesarean': '#ff7f00'}

    fig, axn = plt.subplots(3, 5, figsize=(20, 10), sharex=True)

    simulation_metrics_plot = {}
    for method, ord_ in simulation_metrics[11939][1].items():
        if '\\alpha$=' in method:
            if (int(float(method.split('\\alpha$=')[1][:-1]) * 10) % 2 != 0) \
                    & (float(method.split('\\alpha$=')[1][:-1]) != 0.1):
                continue
        simulation_metrics_plot[method] = ord_

    for (method, ord_), ax in zip(simulation_metrics_plot.items(), axn.T.flatten()):

        if method in ['CTF', 'Phylo-CTF']:
            ord_tmp = ord_[0].copy()
            ord_tmp = ord_tmp.rename({'PC1': 0, 'PC2': 1}, axis=1)
            ord_tmp = ord_tmp.dropna(subset=[0, category])
            ord_tmp = ord_tmp[ord_tmp[category] != 'nan']
            ord_ = ord_[1]
        else:
            ord_tmp = ord_.samples[[0, 1, 2]].copy()
            mf_tmp = metadata.to_dataframe().copy().reindex(ord_tmp.index)
            ord_tmp = pd.concat([ord_tmp, mf_tmp[[category, 'month']]],
                                axis=1, sort=False).dropna(subset=[0, category])
            ord_tmp = ord_tmp[ord_tmp[category] != 'nan']

        sns.scatterplot(x='month', y=0, hue='delivery', data=ord_tmp, ax=ax, palette=pal_use)
        sns.lineplot(x='month', y=0, hue='delivery', data=ord_tmp, ax=ax, palette=pal_use)
        ax.set_title(method,
                     fontsize=18,
                     family='arial',
                     weight='bold',
                     color='black')
        ax.legend_.remove()

        ax.set_facecolor('white')
        ax.set_axisbelow(True)
        ax.spines['right'].set_visible(False)
        ax.spines['left'].set_visible(True)
        ax.spines['bottom'].set_visible(True)
        ax.spines['top'].set_visible(False)

        for child in ax.get_children():
            if isinstance(child, matplotlib.spines.Spine):
                child.set_color('black')
        ax.tick_params(axis='y', colors='black', width=2, length=10)
        ax.tick_params(axis='x', colors='black', width=2, length=10)
        for tick in ax.get_xticklabels():
            tick.set_fontproperties('arial')
            tick.set_ha("right")
            tick.set_color("black")
            tick.set_weight("bold")
            tick.set_fontsize(18)
        for tick in ax.get_yticklabels():
            tick.set_fontproperties('arial')
            tick.set_color("black")
            tick.set_weight("bold")
            tick.set_fontsize(10)
        ax.set_xlabel('time from birth (months)',
                      fontsize=18,
                      family='arial',
                      weight='bold',
                      color='black')
        ax.set_ylabel('PC1 (%.2f%%)' % (ord_.proportion_explained[0] * 100),
                      fontsize=18,
                      family='arial',
                      weight='bold',
                      color='black')

    plt.tight_layout()

    handles, labels = ax.get_legend_handles_labels()
    ax.legend(handles[2:], labels[2:],
              loc=2, bbox_to_anchor=(-3.25, -0.50),
              prop={'size': 18},
              fancybox=True, framealpha=0.5,
              ncol=2, markerscale=3,
              facecolor="white")

    plt.savefig('../../results/figures/birth-mode-scatterplots.pdf', dpi=1000,
                bbox_inches='tight',
                facecolor=fig.get_facecolor(),
                edgecolor='none')

    plt.show()