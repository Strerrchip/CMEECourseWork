from pathlib import Path

import pandas as pd
import matplotlib.pyplot as plt

project_root = Path(__file__).resolve().parents[1]
data = pd.read_csv(project_root / "data" / "LogisticGrowthData.csv")

group_columns = [
    "Citation", "Species", "Temp", "Medium",
    "Rep", "Time_units", "PopBio_units",
]

# Use the same grouping and order as the overview plots.
groups = list(data.groupby(group_columns, dropna=False, sort=True))
curve_id = 41
_, curve = groups[curve_id - 1]
curve = curve.sort_values("Time").copy()
first = curve.iloc[0]

print("Curve ID:", curve_id)
print("Species:", first["Species"])
print("Temperature (C):", first["Temp"])
print("Medium:", first["Medium"])
print("Replicate:", first["Rep"])
print("Source:", first["Citation"])
print("\nObservations:")
print(curve[["Time", "PopBio"]].to_string(index=False))

fig, ax = plt.subplots(figsize=(7, 5))
ax.scatter(curve["Time"], curve["PopBio"], label="Observed data")
ax.set_xlabel("Time (hours)")
ax.set_ylabel(f"Population or biomass ({first['PopBio_units']})")
ax.set_title(f"{first['Species']} at {first['Temp']} °C")
ax.legend()
fig.tight_layout()

results_folder = project_root / "results"
results_folder.mkdir(parents=True, exist_ok=True)
fig.savefig(results_folder / "example_raw_curve.png", dpi=300)
plt.close(fig)