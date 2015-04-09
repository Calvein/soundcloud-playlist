BASE_URL = 'http://ws.audioscrobbler.com/2.0/'
# There is no backend so fuck it
API_SECRET = '6531a456239925b5e32792c5a1c6589d'

crypto = require('crypto')


createParams = (params, joint = '', itemJoint = '') ->
    params = Object.keys(params).sort().map((key) ->
        return key + itemJoint + params[key]
    ).join(joint)

createSignature = (params) ->
    return crypto.createHash('md5')
        .update(createParams(params) + API_SECRET)
        .digest('hex')

getLastFmQuery = (params) ->
    params.api_sig = createSignature(params)
    params.format = 'json'
    return $.ajax(
        url: BASE_URL
        data: params
        type: 'POST'
    )

module.exports =
    createParams: createParams
    createSignature: createSignature
    getLastFmQuery: getLastFmQuery