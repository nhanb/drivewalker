# Common data structures used by both client and server go here
import karax / [kbase] # to use kstring

type Chapter* = object
  name*: kstring
  pages*: seq[kstring]
