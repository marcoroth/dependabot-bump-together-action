FROM dependabot/dependabot-core
USER root

LABEL "repository"="https://github.com/marcoroth/dependabot-bump-together-action"
LABEL "maintainer"="Marco Roth <marco.roth@intergga.ch>"
LABEL "version"="0.2.0"

RUN echo 'gem: --no-document' >> ~/.gemrc

RUN gem install bundler
RUN gem install dependabot-omnibus

WORKDIR /action
COPY lib /action/lib

ENTRYPOINT ["/action/lib/entrypoint.sh"]
