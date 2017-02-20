from invoke import task


DOCKER_COMPOSE_FILES = ['docker-compose-deps.yaml', 'docker-compose.yaml']
DOCKER_COMPOSE_DEFAULTS = dict(
    up=['abort-on-container-exit', 'no-build'],
    down=['volumes']
)


def flags_to_arg_string(flags):
    return ' '.join(['--{}'.format(flag) for flag in flags])


@task(default=True)
def up(ctx, d=False, flags=None):
    flags = DOCKER_COMPOSE_DEFAULTS['up'] + flags or []
    if d:
        flags.append('d')
    ctx.run('docker-compose {} {}'.format('up', flags_to_arg_string(flags)))


@task
def down(ctx, flags=None):
    flags = DOCKER_COMPOSE_DEFAULTS['down'] + flags or []
    ctx.run('docker-compose {} {}'.format('down', flags_to_arg_string(flags)))


@task
def rm(ctx):
    ctx.run('docker-compose {} {}'.format('rm', '-v'))


@task
def build(ctx):
    ctx.run('docker-compose {} {}'.format('build', 'monsterui'))


@task
def rebuild(ctx):
    ctx.run('docker-compose {} {}'.format('build', '--no-cache'))
