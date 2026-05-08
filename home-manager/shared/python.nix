{ 
  pkgs,
  ...
}: {
  home.packages = [(pkgs.python313.withPackages
   (pyPkgs: with pyPkgs; [ # Build a single python derivation with the following packages baked-in and have HM use thatp
     numpy
     pandas
     openpyxl # For XLSX file parsing in pandas
     matplotlib
     tkinter # The GUI backend for plotting
     scikit-learn
     xgboost
     tensorflow
   ])
  )];
}
