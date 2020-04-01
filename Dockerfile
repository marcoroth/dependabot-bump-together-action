ARG INPUT_DEPENDABOT_VERSION
ARG INPUT_BUNDLER_VERSION
ARG TAG=dependabot/dependabot-core:$INPUT_DEPENDABOT_VERSION

FROM $TAG

LABEL "repository"="https://github.com/marcoroth/dependabot-bump-together-action"
LABEL "maintainer"="Marco Roth <marco.roth@intergga.ch>"
LABEL "version"="0.2.0"

RUN echo 'gem: --no-document' >> ~/.gemrc

RUN gem install bundler -v ${INPUT_BUNDLER_VERSION}
RUN gem install dependabot-omnibus -v ${INPUT_DEPENDABOT_VERSION}

WORKDIR /action
COPY lib /action/lib

ENTRYPOINT ["/action/lib/entrypoint.sh"]
