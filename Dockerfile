FROM debian:wheezy as fetch
MAINTAINER OpusVL <dev@opusvl.com>

RUN apt-get update && apt-get install -y curl bzip2
RUN curl https://cpan.metacpan.org/authors/id/D/DA/DAPM/perl-5.14.4.tar.bz2 | tar -jx

FROM debian:wheezy as build
COPY --from=fetch /perl-5.14.4 /perl-5.14.4

RUN apt-get update && apt-get -y install build-essential

WORKDIR /perl-5.14.4

RUN ./Configure -des -Dprefix=/opt/perl-5.14.4
RUN make -j $(nproc)

FROM debian:wheezy as test
COPY --from=build /perl-5.14.4 /perl-5.14.4

RUN apt-get update && apt-get -y install build-essential procps

WORKDIR /perl-5.14.4

RUN make test -j $(nproc)

FROM debian:wheezy as install
COPY --from=build /perl-5.14.4 /perl-5.14.4

RUN apt-get update && apt-get -y install build-essential

WORKDIR /perl-5.14.4

RUN mkdir -p /opt/perl-5.14.4/{bin,lib,man} # fix "Can't open file /opt/perl-5.14.4/lib/5.14.4/x86_64-linux/.packlist: No such file or directory at installman line 205"
RUN make install -j $(nproc)

FROM debian:wheezy as release
COPY --from=install /opt/perl-5.14.4 /opt/perl-5.14.4
RUN ln -s /opt/perl-5.14.4 /opt/perl5

FROM debian:wheezy AS dev
COPY --from=release /opt/perl-5.14.4 /opt/perl-5.14.4
RUN ln -s /opt/perl-5.14.4 /opt/perl5

RUN apt-get update && apt-get install -y build-essential

ENV PERL_MM_USE_DEFAULT 1
RUN /opt/perl5/bin/cpan App::cpanminus

# fix Jenkins bug
