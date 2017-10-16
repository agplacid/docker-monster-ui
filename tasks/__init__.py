import os

from invoke import task, Collection

from . import test, dc, kube, sup


COLLECTIONS = [test, dc, kube, sup]

ns = Collection()
for c in COLLECTIONS:
    ns.add_collection(c)

ns.configure(dict(
    project='monsterui',
    repo='docker-monsterui',
    pwd=os.getcwd(),
    docker=dict(
        user=os.getenv('DOCKER_USER'),
        org=os.getenv('DOCKER_ORG', os.getenv('DOCKER_USER', 'telephoneorg')),
        name='monsterui',
        tag='%s/%s:latest' % (
            os.getenv('DOCKER_ORG', os.getenv('DOCKER_USER', 'telephoneorg')), 'monsterui'
        ),
        shell='bash'
    ),
    kube=dict(
        environment='testing'
    )
))
