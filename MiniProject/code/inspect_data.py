from pathlib import Path
import pandas as pd

# Find the project folder from the location of this script.
project_root = Path(__file__).resolve().parents[1]
data_file = project_root / "data" / "LogisticGrowthData.csv"

data = pd.read_csv(data_file)

print("Number of rows and columns:", data.shape)

print("\nColumn names:")
print(data.columns.tolist())

print("\nFirst five rows:")
print(data.head().to_string(index=False))

print("\nMissing values in each column:")
print(data.isna().sum().to_string())

print("\nTime units:")
print(data["Time_units"].value_counts(dropna=False).to_string())

print("\nPopulation or biomass units:")
print(data["PopBio_units"].value_counts(dropna=False).to_string())

# Keep different studies, conditions and replicates separate.
group_columns = [
    "Citation",
    "Species",
    "Temp",
    "Medium",
    "Rep",
    "Time_units",
    "PopBio_units",
]

curves = (
    data.groupby(group_columns, dropna=False)
    .agg(
        n_points=("Time", "size"),
        n_times=("Time", "nunique"),
        time_min=("Time", "min"),
        time_max=("Time", "max"),
        value_min=("PopBio", "min"),
        value_max=("PopBio", "max"),
    )
    .reset_index()
)

print("\nNumber of candidate growth curves:", len(curves))

print("\nNumber of observations per curve:")
print(curves["n_points"].describe().to_string())

print("\nNumber of curves by measurement unit:")
print(curves["PopBio_units"].value_counts().to_string())

print("\nCurves with repeated time values:")
print((curves["n_points"] > curves["n_times"]).sum())

print("\nObservations with negative time:")
print((data["Time"] < 0).sum())

print("\nObservations with zero or negative population values:")
print((data["PopBio"] <= 0).sum())

# Save the summary without changing the original data.
results_folder = project_root / "results"
results_folder.mkdir(parents=True, exist_ok=True)
curves.to_csv(results_folder / "curve_summary.csv", index=False)