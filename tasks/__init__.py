import os

from invoke import task, Collection

from . import test, dc, hub, kube, sup


COLLECTIONS = [test, dc, hub, kube, sup]

ns = Collection()
for c in COLLECTIONS:
    ns.add_collection(c)

ns.configure(dict(
    project='monster-ui',
    repo='docker-monster-ui',
    pwd=os.getcwd(),
    docker=dict(
        user=os.getenv('DOCKER_USER'),
        org=os.getenv('DOCKER_ORG', os.getenv('DOCKER_USER', 'telephoneorg')),
        name='monster-ui',
        tag='%s/%s:latest' % (
            os.getenv('DOCKER_ORG', os.getenv('DOCKER_USER', 'telephoneorg')), 'monster-ui'
        ),
        shell='bash'
    ),
    kube=dict(
        environment='production'
    ),
    hub=dict(
        images=['monster-ui']
    )
))
