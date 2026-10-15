from pathlib import Path
import textwrap

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

project_root = Path(__file__).resolve().parents[1]
data = pd.read_csv(project_root / "data" / "LogisticGrowthData.csv")

group_columns = [
    "Citation", "Species", "Temp", "Medium",
    "Rep", "Time_units", "PopBio_units",
]

groups = list(data.groupby(group_columns, dropna=False, sort=True))

results_folder = project_root / "results"
results_folder.mkdir(parents=True, exist_ok=True)
output_file = results_folder / "raw_growth_curves.pdf"

# Show each candidate curve separately, without changing the data.
with PdfPages(output_file) as pdf:
    for start in range(0, len(groups), 12):
        fig, axes = plt.subplots(4, 3, figsize=(12, 14))
        axes = axes.ravel()

        for position, ax in enumerate(axes):
            index = start + position

            if index >= len(groups):
                ax.set_visible(False)
                continue

            _, curve = groups[index]
            curve = curve.sort_values("Time")
            first = curve.iloc[0]

            ax.plot(
                curve["Time"],
                curve["PopBio"],
                "o-",
                markersize=3,
                linewidth=0.8,
            )

            species = textwrap.fill(str(first["Species"]), width=30)
            ax.set_title(
                f"Curve {index + 1:03d}: {species}\n"
                f"{first['Temp']} °C; Rep {first['Rep']}; "
                f"n = {len(curve)}",
                fontsize=8,
            )
            ax.set_xlabel("Time (hours)", fontsize=8)
            ax.set_ylabel(str(first["PopBio_units"]), fontsize=8)
            ax.tick_params(labelsize=7)
            ax.grid(alpha=0.2)

        fig.tight_layout()
        pdf.savefig(fig)
        plt.close(fig)

print(f"Saved {len(groups)} curves to: {output_file}")