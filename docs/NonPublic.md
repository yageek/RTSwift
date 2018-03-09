# Non public API

The public API does not seems to provide access to the HLS stream of elements

Analyzing the behaviour of the HTML player let seems to have a scheme to get the URL of the HLS:

From the URN of the player, call this url: http://il.srgssr.ch/integrationlayer/2.0/mediaComposition/byUrn/{{URN}}.json?onlyChapters=true&vector=portalplay

Inside the returned payload, you may retrieve an url to an MP4 on the keypath on `show.podcastSubscriptionUrl`.

The link for the different streamed elements are located inside the `chapterList` array. Each item in this array has a `resourceList` property containing
a list of all the different streams.

Once you selected the streams by its URL, you first need to get a token from AKAMAI server.

Imagine the stream URL has the following URL:
```
https://rtsvodww-vh.akamaihd.net/i/tempr/2018/tempr_20180222_full_563704-,301k,101k,701k,1201k,2001k,3501k,6001k,.mp4.csmil/master.m3u8
```
Keep in mind the beginning of the path:
```
/i/tempr/2018/tempr_20180222_full_563704-,301k,101k,701k,1201k,2001k,3501k,6001k,.mp4.csmil/master.m3u8
```

You need to call akamai to get a token for a keypath:
```
GET http://tp.srgssr.ch/akahd/token?acl=/i/tempr/*
```

This answers:
```
{"token":{"window":30,"acl":"/i/*","authparams":"hdnts=exp=1520600964~acl=/i/*~hmac=af76aee0d0319050219e9de7d82c5233a98788d604a381832aaf6eacacc2a155"}}
```

Now simply use the `authparams` as the query parameter for the stream URL:

```
https://rtsvodww-vh.akamaihd.net/i/tempr/2018/tempr_20180222_full_563704-,301k,101k,701k,1201k,2001k,3501k,6001k,.mp4.csmil/master.m3u8?hdnts=exp=1520600964~acl=/i/*~hmac=af76aee0d0319050219e9de7d82c5233a98788d604a381832aaf6eacacc2a155
```

