# Common data structures used by both client and server go here
import karax / [kbase] # to use kstring

type GdriveCredentials* = object
  appId*: kstring
  appSecret*: kstring
  refreshToken*: kstring
