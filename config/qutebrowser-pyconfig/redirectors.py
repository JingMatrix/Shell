# https://gitlab.com/jgkamat/dotfiles/-/blob/master/qutebrowser/.config/qutebrowser/pyconfig/redirectors.py

import operator
import typing

from qutebrowser.api import interceptor, message

REDIRECT_MAP = {
    "reader.epubee.com": operator.methodcaller('setHost', 'reader.obook.vip'),
    "doi.org": operator.methodcaller('setHost', 'sci-hub.se'),
}  # type: typing.Dict[str, typing.Callable[..., typing.Optional[bool]]]


def int_fn(info: interceptor.Request):
    """Block the given request if necessary."""
    if (info.resource_type != interceptor.ResourceType.main_frame or
            info.request_url.scheme() in {"data", "blob"}):
        return
    url = info.request_url
    redir = REDIRECT_MAP.get(url.host())
    if redir is not None and redir(url) is not False:
        message.info("Redirecting to " + url.toString())
        info.redirect(url)


interceptor.register(int_fn)
