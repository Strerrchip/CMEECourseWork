"""Plot saved fits: flagged curves by default, one curve, or all curves."""

import argparse
from pathlib import Path
import textwrap

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd


COLORS = {
    "Exponential": "steelblue",
    "Logistic": "darkorange",
    "Gompertz": "seagreen",
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument("--curve", help="Plot just one curve, such as C065.")
    selection.add_argument("--all", action="store_true", help="Plot all screened curves.")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    results = root / "results"
    review_folder = results / "review"
    review = pd.read_csv(review_folder / "curve_fit_review.csv")
    fits = pd.read_csv(review_folder / "merged_model_fits.csv")
    predictions = pd.read_csv(review_folder / "merged_predictions.csv")
    data = pd.read_csv(results / "prepared_growth_data.csv")

    if args.curve:
        identifiers = [args.curve]
    elif args.all:
        identifiers = sorted(review["curve_id"].unique().tolist())
    else:
        identifiers = review.loc[
            review["review_category"].ne("Complete comparison; no numerical flags"),
            "curve_id",
        ].tolist()
        identifiers = sorted(set(identifiers + ["C041"]))

    folder = review_folder / "diagnostic_plots"
    folder.mkdir(parents=True, exist_ok=True)
    index_rows = []

    for position, identifier in enumerate(identifiers, start=1):
        metadata = review.loc[review["curve_id"].eq(identifier)]
        if len(metadata) != 1:
            raise ValueError(f"Curve is missing or repeated: {identifier}")
        metadata = metadata.iloc[0]
        curve = data.loc[data["curve_id"].eq(identifier)].sort_values("time_since_first")
        curve_fits = fits.loc[fits["curve_id"].eq(identifier)]
        curve_predictions = predictions.loc[predictions["curve_id"].eq(identifier)]

        fig, axes = plt.subplots(2, 1, figsize=(9, 8), sharex=True)
        axes[0].scatter(
            curve["time_since_first"], curve["PopBio"],
            color="black", s=25, label="Observed data", zorder=3,
        )

        notes = []
        for name, color in COLORS.items():
            fitted = curve_fits.loc[curve_fits["model"].eq(name)].iloc[0]
            if fitted["status"] != "converged":
                notes.append(f"{name}: fitting failed")
                continue
            table = curve_predictions.loc[curve_predictions["model"].eq(name)]
            table = table.sort_values("time_since_first")
            if len(table) != len(curve):
                raise ValueError(f"Prediction count does not match: {identifier}, {name}")
            # Lines join predictions at observed times, rather than a smooth grid.
            axes[0].plot(
                table["time_since_first"], table["predicted"],
                color=color, linewidth=1.5, label=name,
            )
            axes[1].scatter(
                table["time_since_first"], table["residual"],
                color=color, s=20, alpha=0.8, label=name,
            )
            flag = str(fitted["numerical_review"]).lower() == "true"
            notes.append(f"{name}: numerical review {'needed' if flag else 'not flagged'}")

        title = textwrap.fill(
            f"{identifier}: {metadata['Species']} at {metadata['Temp']} C", width=65
        )
        axes[0].set_title(title)
        axes[0].set_ylabel(f"Growth measurement ({metadata['PopBio_units']})")
        axes[0].legend(fontsize=9)
        axes[1].axhline(0, color="black", linewidth=1)
        axes[1].set_xlabel("Time since first observation (hours)")
        axes[1].set_ylabel("Observed - predicted")
        axes[1].legend(fontsize=9)
        for ax in axes:
            ax.grid(alpha=0.2)

        context = f"Medium: {metadata['Medium']}; replicate: {metadata['Rep']}; n = {len(curve)}"
        footer = context + "\n" + "; ".join(notes)
        fig.text(0.08, 0.02, textwrap.fill(footer, width=105), fontsize=8)
        fig.tight_layout(rect=(0, 0.09, 1, 1))
        filename = f"{identifier}_diagnostics.png"
        fig.savefig(folder / filename, dpi=150)
        plt.close(fig)

        index_rows.append({
            "curve_id": identifier,
            "plot_file": filename,
            "review_category": metadata["review_category"],
            "Species": metadata["Species"],
            "Temp": metadata["Temp"],
        })
        print(f"Saved {position}/{len(identifiers)}: {filename}", flush=True)

    index_name = (
        f"index_{args.curve}.csv" if args.curve
        else "plot_index_all.csv" if args.all
        else "plot_index.csv"
    )
    pd.DataFrame(index_rows).to_csv(folder / index_name, index=False)
    print(f"\nSaved plots to: {folder}")
    print("These are review plots, not final report figures.")


if __name__ == "__main__":
    main()
