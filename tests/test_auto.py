from __future__ import absolute_import


def test_main():
    from forkmixer.auto import forkmixer

    assert mixer


def test_django():
    from django.core.management import call_command
    from forkmixer.auto import forkmixer

    from .django_app.models import Rabbit

    call_command('migrate', interactive=False)

    rabbit = mixer.blend(Rabbit)
    assert rabbit

    rabbit = mixer.blend('tests.django_app.models.Rabbit')
    assert rabbit

    rabbits = mixer.cycle(2).blend(Rabbit)
    assert all(rabbits)

    call_command('flush', interactive=False)


def test_sqlalchemy():
    from forkmixer.auto import forkmixer
    from .test_sqlalchemy import User

    user = mixer.blend(User)
    assert user

    user = mixer.blend('tests.test_sqlalchemy.User')
    assert user

    users = mixer.cycle(2).blend(User)
    assert all(users)


def test_mongoengine():
    from forkmixer.backend.mongoengine import mixer as m
    m.params['commit'] = False

    from forkmixer.auto import forkmixer

    from .test_mongoengine import User

    user = mixer.blend(User)
    assert user

    user = mixer.blend('tests.test_mongoengine.User')
    assert user

    users = mixer.cycle(2).blend(User)
    assert all(users)
