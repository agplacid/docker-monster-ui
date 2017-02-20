from invoke import task


@task(default=True)
def init(ctx, environment=None):
    environment = environment or 'kube'
    ctx.run('do-{} all'.format(environment), pty=True)
