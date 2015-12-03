request = require 'request'
Promise = require 'broken'

XhrClient = require './xhr'

{newError} = require '../utils'

module.exports = class NodeClient extends XhrClient
  request: (blueprint, data, key = @getKey()) ->
    opts =
      url:    @getUrl blueprint.url, data, key
      method: blueprint.method

    if (opts.method is 'POST') or (opts.method is 'PATCH')
      opts.json = data
    else
      opts.json = true

    if @debug
      console.log '--REQUEST--'
      console.log opts

    new Promise (resolve, reject) =>
      request opts, (err, res) =>
        res.status = res.statusCode
        res.data   = res.body

        if @debug
          console.log '--RESPONSE--'
          console.log res.toJSON()

        if err? or (res.status > 308) or res.data?.error?
          err = newError opts, res
          console.log 'ERROR:', err if @debug
          return reject err

        resolve
          url:          opts.url
          req:          opts
          res:          res
          data:         res.data
          responseText: res.data
          status:       res.status
          statusText:   res.statusText
          headers:      res.headers
