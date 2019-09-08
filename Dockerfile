FROM elixir:1.9.1

WORKDIR /app
ADD . /app

# Install hex & rebar
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

EXPOSE 4000

# Intall phoenix
ENV PHOENIX_VERSION=1.4.10
RUN mix archive.install --force hex phx_new ${PHOENIX_VERSION}
RUN mix deps.get
# RUN mix ecto.create && mix ecto.migrate && mix insert_data
# RUN mix run -e "Exfootball.import_matches_from_csv(\"../input_csv_files/Data.csv\")"
#CMD ["sleep", "infinity"]
