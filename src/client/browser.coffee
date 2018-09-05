import Xhr from 'es-xhr-promise'

import Client     from './client'
import {newError, updateQuery} from '../utils'

class BrowserClient extends Client
  constructor: (opts) ->
    return new BrowserClient opts unless @ instanceof BrowserClient
    super opts
    @getCustomerToken()

  request: (blueprint, opts={}, key = @getKey()) ->
    if opts.data?
      data = opts.data
    else
      data = opts

    opts.url     = @url blueprint.url, data, key
    opts.method  = blueprint.method
    opts.headers = 'Content-Type': 'application/json'

    if blueprint.method == 'GET'
      opts.url  = updateQuery opts.url, data
    else
      opts.data = JSON.stringify data

    @log 'request', key: key, opts: opts

    (new Xhr).send opts
      .then (res) =>
        @log 'response', res
        res.data = res.responseText
        res
      .catch (res) =>
        try
          res.data = res.responseText ? (JSON.parse res.xhr.responseText)
        catch err

        err = newError data, res, err
        @log 'response', res
        @log 'error', err

        throw err

export default BrowserClient
