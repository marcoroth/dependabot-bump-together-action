FROM ghcr.io/dependabot/dependabot-core:latest
USER root

LABEL "repository"="https://github.com/marcoroth/dependabot-bump-together-action"
LABEL "version"="0.3.0"

RUN echo 'gem: --no-document' >> ~/.gemrc

RUN gem install bundler
RUN gem install dependabot-omnibus

WORKDIR /action
COPY lib /action/lib

ENTRYPOINT ["/action/lib/entrypoint.sh"]
