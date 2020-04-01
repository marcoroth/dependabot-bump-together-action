FROM dependabot/dependabot-core:0.117.5

LABEL "repository"="https://github.com/marcoroth/dependabot-bump-together-action"
LABEL "maintainer"="Marco Roth <marco.roth@intergga.ch>"
LABEL "version"="0.1.1"

RUN echo 'gem: --no-document' >> ~/.gemrc

RUN gem install bundler -v 2.0.2
RUN gem install dependabot-omnibus -v 0.117.5

WORKDIR /action
COPY lib /action/lib

ENTRYPOINT ["/action/lib/entrypoint.sh"]
