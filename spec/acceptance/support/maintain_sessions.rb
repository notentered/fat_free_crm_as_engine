#
# Workaround for ActionDispatch::ClosedError
# https://github.com/binarylogic/authlogic/issues/262#issuecomment-1804988
#
FatFreeCRM.user_class.acts_as_authentic_config[:maintain_sessions] = false
