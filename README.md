# Comparative FEM Study on Intervertebral Disc Modeling: Holzapfel-Gasser-Ogden vs. Structural Rebars

This is the official code and data repository for the paper "Comparative FEM Study on Intervertebral Disc Modeling: Holzapfel-Gasser-Ogden vs. Structural Rebars". 

![DOI](https://zenodo.org/badge/DOI/DoNotUseAtTheMoment.svg)

## Content

The repository contains the MATLAB and Python code for conducting a comparative finite element (FE) analysis on three models of the human L4-L5 intervertebral disc. Our comprehensive research pipeline includes the following sequential stages:
- **Sensitivity Analysis**: Running initial simulations to identify key parameters influencing the behavior of the FE models.
- **Model Calibration**: Fine-tuning the FE models to align with experimental range of motion (ROM) data obtained from in vitro studies.
- **Model Validation**: Assessing the performance of the calibrated models by comparing predicted range of motion and intradiscal pressure measurements against experimental data.

The code features a model that employs the anisotropic Holzapfel-Gasser-Ogden (HGO) material formulation to represent the mechanical behavior of the annulus fibrosus. This model is systematically compared with two alternative approaches that utilize the Mooney-Rivlin material model for the annulus fibrosus and incorporate structural rebar elements to simulate the fibrous reinforcements. One model has a linear-elastic material definition for the rebar elements, while the other employs a hyperelastic formulation, thereby deriving two variant models. Despite these differences, a consistent Mooney-Rivlin material model is applied across all three models to characterize the nucleus pulposus, ensuring a controlled comparison of the annulus fibrosus representations.

**Implemented pipeline:**
![CompletePipeline](https://github.com/GruberGabriel/ComparativeAnalysisFEModelsIVD/assets/159779728/f55ac76e-2db5-4a95-bfab-2222df425f65)


**Different calibration steps:**
![CalibrationProcess](https://github.com/GruberGabriel/ComparativeAnalysisFEModelsIVD/assets/159779728/dc5911ca-5848-4f87-b240-971eac443e71)

## Software Versions

This code has been developed and tested using the following software versions:

- Abaqus® (version 2023)
- MATLAB® (version R2023a)
- Python 3.9 (Compatibility with any Python 3.x version.)

## Citation

If you use this code for your research, please cite it as follows:

[Placeholder for the complete citation of the paper: the citation will be added after publication.]

We kindly request that you cite our work in any publications that leverage this codebase. This will facilitate proper acknowledgment and enable others to locate the original work.


## Funding

The research for this article received funding from the European Research Council (ERC) under the European Union’s Horizon 2020 research and innovation program. Grant no.: 101045128-iBack-epic-ERC-2021-COG.
