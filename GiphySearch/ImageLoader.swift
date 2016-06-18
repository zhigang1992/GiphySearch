//
//  ImageLoader.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import Nuke
import NukeAlamofirePlugin
import NukeAnimatedImagePlugin

func setupImageLoader() {
    let decoder = ImageDecoderComposition(decoders: [AnimatedImageDecoder(), ImageDecoder()])
    let loader = ImageLoader(
        configuration: ImageLoaderConfiguration(dataLoader: AlamofireImageDataLoader(), decoder: decoder), delegate: AnimatedImageLoaderDelegate())
    let cache = AnimatedImageMemoryCache()
    ImageManager.shared = ImageManager(configuration: ImageManagerConfiguration(loader: loader, cache: cache))
}
