FROM python:3.7.17-slim

RUN \
  apt-get update && apt-get install --yes --no-install-recommends g++ libgomp1 \
  \
  && pip install --no-cache-dir --upgrade pip \
  \
  && pip install --no-cache-dir \
      numpy \
      convertdate \
      dtaidistance \
      lunarcalendar \
      holidays==0.24 \
      plotly \
      psutil \
      lightgbm \
      pystan==2.19.1.1 \
      statsforecast \
      tslearn \
      scikit-hts[auto_arima] \
  \
  && pip install --no-cache-dir \
      scikit-hts[prophet] \
  \
  && apt remove --yes g++ && apt autoremove --yes


