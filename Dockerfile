ARG INPUT_DEPENDABOT_VERSION=0.171.2
ARG image=dependabot/dependabot-core
ARG TAG=${image}:${INPUT_DEPENDABOT_VERSION}

FROM $TAG
USER root
# INPUT_DEPENDABOT_VERSION just defaults to 0.171.2 if nothing was provided
ARG INPUT_DEPENDABOT_VERSION=0.171.2
ENV DEPENDABOT_VERSION="${INPUT_DEPENDABOT_VERSION}"

# INPUT_BUNDLER_VERSION just defaults to 2.3.5 if nothing was provided
ARG INPUT_BUNDLER_VERSION=2.3.5
ENV BUNDLER_VERSION="${INPUT_BUNDLER_VERSION}"

LABEL "repository"="https://github.com/marcoroth/dependabot-bump-together-action"
LABEL "maintainer"="Marco Roth <marco.roth@intergga.ch>"
LABEL "version"="0.2.0"

RUN echo 'gem: --no-document' >> ~/.gemrc

RUN gem install bundler -v $BUNDLER_VERSION
RUN gem install dependabot-omnibus -v $DEPENDABOT_VERSION

WORKDIR /action
COPY lib /action/lib

ENTRYPOINT ["/action/lib/entrypoint.sh"]
