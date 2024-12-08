{
  lib,
  buildPythonPackage,
  cython,
  numpy,
  pytestCheckHook,
  scipy,
  scikit-learn,
  fetchPypi,
  joblib,
  six,
  setuptools,
  pythonAtLeast,
}:

buildPythonPackage rec {
  pname = "hdbscan";
  version = "0.8.40";
  pyproject = true;
  disabled = pythonAtLeast "3.12";

  build-system = [
    setuptools
  ];

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-yeOD/xe+7gWRB1/2XVJL2ltaNd+wHSGCRae6MMjUihc=";
  };

  dependencies = [
    numpy
    scipy
    scikit-learn
    joblib
    six
    cython
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # known flaky tests: https://github.com/scikit-learn-contrib/hdbscan/issues/420
    "test_mem_vec_diff_clusters"
    "test_all_points_mem_vec_diff_clusters"
    "test_approx_predict_diff_clusters"
    # another flaky test https://github.com/scikit-learn-contrib/hdbscan/issues/421
    "test_hdbscan_boruvka_balltree_matches"
    # more flaky tests https://github.com/scikit-learn-contrib/hdbscan/issues/570
    "test_hdbscan_boruvka_balltree"
    "test_hdbscan_best_balltree_metric"
  ];

  pythonImportsCheck = [ "hdbscan" ];

  meta = {
    description = "Hierarchical Density-Based Spatial Clustering of Applications with Noise, a clustering algorithm with a scikit-learn compatible API";
    homepage = "https://github.com/scikit-learn-contrib/hdbscan";
    license = lib.licenses.bsd3;
  };
}
