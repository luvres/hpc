FROM python:3.7.16-slim

RUN \
  apt update && apt install --yes --no-install-recommends g++ \
  \
  && pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir \
      scikit-hts[auto_arima] \
      scikit-hts[prophet] \
      dtaidistance \
      plotly \
  \
  && apt remove --yes g++ && apt autoremove --yes
