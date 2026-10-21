# HPC coursework status on 21 October 2026

Both cluster arrays have completed. Task files and logs have been downloaded, and Questions 5-6 and 26 have been processed from the complete real results.

## Cluster run records

| Array | Tasks | PBS job ID |
|---|---|---|
| Demographic initial checks | 1-3 | 4415941[].pbs-7 |
| Demographic remaining tasks | 4-100 | 4416041[].pbs-7 |
| Neutral initial checks | 1-3 | 4416059[].pbs-7 |
| Neutral remaining tasks | 4-100 | 4419800[].pbs-7 |

The environment was Imperial CX3 with PBS and R/4.4.2-gfbf-2024a. Both submitted shell scripts include the verified module load.

## Downloaded results and checks

- Demographic: 100/100 task files; processing reported 15,000 simulations across four initial conditions.
- Neutral: 100/100 task files; all 100 task output logs contain a completion message.
- Logs: 200 standard-output files (.OU) and 200 error files (.ER); all downloaded error files are empty.
- Required non-challenge function signatures: 25 passed the preparation check.
- Sourcing the main file caused no printing, simulation output, graphics, random-number state changes or working-directory changes.
- R syntax, shell line endings, identity fields and saved personal rate passed the preparation check.
- Questions 5-6: graphs, numerical tables and English answers generated from all demographic results.
- Question 26: neutral summary data, per-task summary table and four-panel abundance distribution graph generated from all neutral results.

The local Question 23 five-minute test remains explicitly labelled local. It is separate from the real neutral cluster runs. Optional challenges are not claimed as completed.

## Access history

The first GitHub upload on 19 October recorded local preparation while Unified Access/Zscaler permissions prevented cluster access. SSH access was verified after ICT correction that day. Demographic jobs completed on 19 October; neutral jobs ran across 19-21 October. Eight neutral tasks finished later than the others. Completion messages and the absence of active jobs were checked before final processing; the presence of 100 data files alone was not treated as proof of completion.

This records observed execution and checks. It does not claim a marking outcome or approval of a deadline extension.
