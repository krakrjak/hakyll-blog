--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid ((<>), mappend)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["humans.txt", "robots.txt"]) $ do
        route   idRoute
        compile copyFileCompiler

    match "contact.markdown" $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["sitemap.xml"] $ do
	let sitemapCtx = listField "posts" postCtx (recentFirst =<< loadAll "posts/*")
                      <> defaultContext
        route idRoute
        compile $ makeItem ""
            >>= loadAndApplyTemplate "templates/sitemap.html" sitemapCtx

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
               let atomCtx = postCtx <> bodyField "description"
               posts <- recentFirst =<< loadAllSnapshots "posts/*" "content"
               renderAtom feedconfig atomCtx posts

    create ["rss.xml"] $ do
        route idRoute
        compile $ do
            let rssCtx = postCtx <> bodyField "description" 
            posts <- recentFirst =<< loadAllSnapshots "posts/*" "content"
            renderRss feedconfig rssCtx posts

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" defaultRoute
    match "/" defaultRoute

    match "templates/*" $ compile templateCompiler

--------------------------------------------------------------------------------
defaultRoute = do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls



--------------------------------------------------------------------------------
feedconfig :: FeedConfiguration
feedconfig = FeedConfiguration { feedTitle       = "krakrjak"
                               , feedDescription = "Regular Blog"
                               , feedAuthorName  = "Zac Slade"
                               , feedAuthorEmail = "<krakrjak@gmail.com>"
                               , feedRoot        = "http://krakrjak.com" }

postCtx :: Context String
postCtx = dateField  "date"     "%B %e, %Y"
       <> dateField  "isodate"  "%F"
       <> constField "siteroot" (feedRoot feedconfig)
       <> defaultContext
