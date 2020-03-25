FROM dependabot/dependabot-core

LABEL "repository"="https://github.com/marcoroth/dependabot-bump-together-action"
LABEL "maintainer"="Marco Roth <marco.roth@intergga.ch>"
LABEL "version"="0.1.0"

RUN echo 'gem: --no-document' >> ~/.gemrc

WORKDIR /action
COPY lib /action/lib

RUN gem install bundler
RUN gem install dependabot-omnibus

ENTRYPOINT ["/action/lib/entrypoint.sh"]
