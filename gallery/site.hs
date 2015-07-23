--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid
import           Hakyll
import           Data.Map as M (lookup)
import           Data.Maybe


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- http://javran.github.io/posts/2014-03-01-add-tags-to-your-hakyll-blog.html
    tags <- buildTags "theme/*" (fromCapture "tags/*.html")

    tagsRules tags $ \tag pattern -> do   
      let title = "Themes tagged \'" ++ tag ++ "\'" 
      route idRoute 
      compile $ do 
          posts <- recentFirst =<< loadAll pattern 
          let ctx = 
                constField "title" title <>
                listField "posts" postCtx (return posts) <>
                defaultContext 

          makeItem "" 
              >>= loadAndApplyTemplate "templates/tag.html" ctx 
              >>= loadAndApplyTemplate "templates/default.html" ctx 
              >>= relativizeUrls

    match "theme/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags tags)
            >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags)
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "theme/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) <>
                    constField "title" "All Themes"          <>
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx 
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 10) . recentFirst =<< 
              loadAll "theme/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) <>
                    constField "title" "Recent Themes"       <>
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" <>
    mainImgCtx <> downloadCtx <> demoUrlCtx <>
    defaultContext

postCtxWithTags :: Tags -> Context String 
postCtxWithTags tags = tagsField "tags" tags <> postCtx

mainImgCtx :: Context String 
mainImgCtx = 
  field "cover" $ \item -> do
      identifier <- getUnderlying 
      metadata <- getMetadata (itemIdentifier item)
      return $ fromMaybe "blank.png" $ M.lookup "cover" metadata

demoUrlCtx :: Context String 
demoUrlCtx = 
  field "demoUrl" $ \item -> do
      identifier <- getUnderlying 
      metadata <- getMetadata (itemIdentifier item)
      return $ fromMaybe "" $ M.lookup "demo" metadata

downloadCtx :: Context String 
downloadCtx = 
  field "downloadUrl" $ \item -> do
      identifier <- getUnderlying 
      metadata <- getMetadata (itemIdentifier item)
      return $ fromMaybe "" $ M.lookup "download" metadata
