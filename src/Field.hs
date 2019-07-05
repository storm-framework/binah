{-# LANGUAGE GADTs, TypeFamilies, GeneralizedNewtypeDeriving, PartialTypeSignatures, QuasiQuotes, TemplateHaskell, MultiParamTypeClasses #-}
{-@ LIQUID "--no-pattern-inline" @-}
module Field where

import Data.Functor.Const
import Data.Text (Text)
import Data.Aeson (ToJSON, FromJSON)
import Database.Persist hiding ((==.), (<-.), selectList) --(PersistField, PersistValue, PersistEntity, Key, EntityField, Unique, Filter, fieldLens, Entity(Entity))
import qualified Database.Persist
import qualified Database.Persist.Sqlite
import qualified Database.Persist.TH
import qualified Data.Text
import qualified Data.Proxy
import qualified Data.Map.Internal
import qualified GHC.Int
import Control.Monad.Trans.Class (MonadTrans(..))
import Control.Monad.IO.Class (MonadIO)
import Control.Monad.Reader (ReaderT)
import Database.Persist.TH (mkPersist, sqlSettings, persistLowerCase)
import Database.Persist.Sql (SqlBackend)
-- * Models
-- class PersistEntity record where
--   data Key record
--   data EntityField record :: * -> *
--   data Unique record

--   keyToValues :: Key record -> [PersistValue]
--   keyFromValues :: [PersistValue] -> Either Text (Key record)
--   persistIdField :: EntityField record (Key record)

{-@
data EntityFieldWrapper record typ <policy :: Entity record -> Entity User -> Bool, selector :: Entity record -> typ -> Bool, inverseselector :: typ -> Entity record -> Bool> = EntityFieldWrapper _
@-}
data EntityFieldWrapper record typ = EntityFieldWrapper (EntityField record typ)
{-@ data variance EntityFieldWrapper covariant covariant contravariant invariant invariant @-}

{-@ measure entityKey @-}
entityKey :: Entity record -> Key record
entityKey (Entity key _) = key

{-@ measure entityVal @-}
entityVal :: Entity record -> record
entityVal (Entity _ val) = val

-- {-@
-- data Entity record = Entity
--   { entityKey :: _
--   , entityVal :: _
--   }
-- @-}
-- data Entity record = Entity
--   { entityKey :: Key record
--   , entityVal :: record
--   }

-- ** User
{-@
data User = User
  { userName :: _
  , userFriend :: _
  , userSSN :: {v:_ | len v == 9}
  }
@-}

-- data User = User
--   { userName :: String
--   , userFriend :: Key User
--   , userSSN :: String
--   } deriving (Eq, Show)

-- instance PersistEntity User where
--   newtype Key User = UserKey Int
--     deriving (PersistField, ToJSON, FromJSON, Show, Read, Eq, Ord)

--   data EntityField User typ where
--     UserId :: EntityField User (Key User)
--     UserName :: EntityField User String
--     UserFriend :: EntityField User (Key User)
--     UserSSN :: EntityField User String

--   data Unique User

--   keyToValues = undefined
--   keyFromValues = undefined
--   persistIdField = UserId

-- TODO: This complains about fromPersistValues, which is legitimate. What should we do?

mkPersist sqlSettings [persistLowerCase|
User
  name String
  friend UserId
  sSN String

TodoItem
  owner UserId
  task String

Share
  from UserId
  to UserId
|]


-- mapLeft :: (a -> b) -> Either a c -> Either b c
-- mapLeft _ (Right x) = Right x
-- mapLeft f (Left x) = Left (f x)

-- headNote :: [b] -> b
-- headNote = head

-- fieldError :: Text -> a -> Text
-- fieldError err _ = err

-- data User = User {userName :: !String,
--               userFriend :: !(Key User),
--               userSSN :: !String}
--       deriving ()
-- type UserId = Key User
-- instance PersistEntity User where
--   type PersistEntityBackend User = Database.Persist.Sqlite.SqlBackend
--   data Unique User
--   newtype Key User
--     = UserKey {unUserKey :: (Database.Persist.Sqlite.BackendKey Database.Persist.Sqlite.SqlBackend)}
--     deriving (Show,
--               Read,
--               Eq,
--               Ord,
--               PersistField,
--               ToJSON,
--               FromJSON)
--   data EntityField User typ
--     = typ ~ Key User => UserId |
--       typ ~ String => UserName |
--       typ ~ Key User => UserFriend |
--       typ ~ String => UserSSN
--   keyToValues
--     = ((: []) . (Database.Persist.Sqlite.toPersistValue . unUserKey))
--   keyFromValues
--     = (fmap UserKey
--          . (Database.Persist.Sqlite.fromPersistValue
--               . headNote))
--   entityDef _
--     = (((((((((Database.Persist.Sqlite.EntityDef
--                  (Database.Persist.Sqlite.HaskellName
--                     (Database.Persist.TH.packPTH "User")))
--                 (Database.Persist.Sqlite.DBName
--                    (Database.Persist.TH.packPTH "user")))
--                (((((((Database.Persist.Sqlite.FieldDef
--                         (Database.Persist.Sqlite.HaskellName
--                            (Database.Persist.TH.packPTH "Id")))
--                        (Database.Persist.Sqlite.DBName
--                           (Database.Persist.TH.packPTH "id")))
--                       ((Database.Persist.Sqlite.FTTypeCon Nothing)
--                          (Database.Persist.TH.packPTH "UserId")))
--                      Database.Persist.Sqlite.SqlInt64)
--                     [])
--                    True)
--                   ((Database.Persist.Sqlite.ForeignRef
--                       (Database.Persist.Sqlite.HaskellName
--                          (Database.Persist.TH.packPTH "User")))
--                      ((Database.Persist.Sqlite.FTTypeCon
--                          (Just (Database.Persist.TH.packPTH "Data.Int")))
--                         (Database.Persist.TH.packPTH "Int64")))))
--               [])
--              [((((((Database.Persist.Sqlite.FieldDef
--                       (Database.Persist.Sqlite.HaskellName
--                          (Database.Persist.TH.packPTH "name")))
--                      (Database.Persist.Sqlite.DBName
--                         (Database.Persist.TH.packPTH "name")))
--                     ((Database.Persist.Sqlite.FTTypeCon Nothing)
--                        (Database.Persist.TH.packPTH "String")))
--                    Database.Persist.Sqlite.SqlString)
--                   [])
--                  True)
--                 Database.Persist.Sqlite.NoReference,
--               ((((((Database.Persist.Sqlite.FieldDef
--                       (Database.Persist.Sqlite.HaskellName
--                          (Database.Persist.TH.packPTH "friend")))
--                      (Database.Persist.Sqlite.DBName
--                         (Database.Persist.TH.packPTH "friend")))
--                     ((Database.Persist.Sqlite.FTTypeCon Nothing)
--                        (Database.Persist.TH.packPTH "UserId")))
--                    (Database.Persist.Sqlite.sqlType
--                       (Data.Proxy.Proxy :: Data.Proxy.Proxy GHC.Int.Int64)))
--                   [])
--                  True)
--                 ((Database.Persist.Sqlite.ForeignRef
--                     (Database.Persist.Sqlite.HaskellName
--                        (Database.Persist.TH.packPTH "User")))
--                    ((Database.Persist.Sqlite.FTTypeCon
--                        (Just (Database.Persist.TH.packPTH "Data.Int")))
--                       (Database.Persist.TH.packPTH "Int64"))),
--               ((((((Database.Persist.Sqlite.FieldDef
--                       (Database.Persist.Sqlite.HaskellName
--                          (Database.Persist.TH.packPTH "sSN")))
--                      (Database.Persist.Sqlite.DBName
--                         (Database.Persist.TH.packPTH "s_s_n")))
--                     ((Database.Persist.Sqlite.FTTypeCon Nothing)
--                        (Database.Persist.TH.packPTH "String")))
--                    Database.Persist.Sqlite.SqlString)
--                   [])
--                  True)
--                 Database.Persist.Sqlite.NoReference])
--             [])
--            [])
--           [])
--          (Data.Map.Internal.fromList []))
--         False
--   toPersistFields (User x_a8yr x_a8ys x_a8yt)
--     = [Database.Persist.Sqlite.SomePersistField x_a8yr,
--        Database.Persist.Sqlite.SomePersistField x_a8ys,
--        Database.Persist.Sqlite.SomePersistField x_a8yt]
--   fromPersistValues
--     [x1_a8yv, x2_a8yw, x3_a8yx]
--     = User
--         <$>
--           (mapLeft
--              (fieldError
--                 (Database.Persist.TH.packPTH "name"))
--              . Database.Persist.Sqlite.fromPersistValue)
--             x1_a8yv
--         <*>
--           (mapLeft
--              (fieldError
--                 (Database.Persist.TH.packPTH "friend"))
--              . Database.Persist.Sqlite.fromPersistValue)
--             x2_a8yw
--         <*>
--           (mapLeft
--              (fieldError
--                 (Database.Persist.TH.packPTH "sSN"))
--              . Database.Persist.Sqlite.fromPersistValue)
--             x3_a8yx
--   fromPersistValues x_a8yu
--     = (Left
--          $ (mappend
--               (Database.Persist.TH.packPTH
--                  "User: fromPersistValues failed on: "))
--              (Data.Text.pack $ show x_a8yu))
--   persistUniqueToFieldNames _
--     = error "Degenerate case, should never happen"
--   persistUniqueToValues _
--     = error "Degenerate case, should never happen"
--   persistUniqueKeys
--     (User _name_a8yy _friend_a8yz _sSN_a8yA)
--     = []
--   persistFieldDef UserId
--     = ((((((Database.Persist.Sqlite.FieldDef
--               (Database.Persist.Sqlite.HaskellName
--                  (Database.Persist.TH.packPTH "Id")))
--              (Database.Persist.Sqlite.DBName
--                 (Database.Persist.TH.packPTH "id")))
--             ((Database.Persist.Sqlite.FTTypeCon Nothing)
--                (Database.Persist.TH.packPTH "UserId")))
--            Database.Persist.Sqlite.SqlInt64)
--           [])
--          True)
--         ((Database.Persist.Sqlite.ForeignRef
--             (Database.Persist.Sqlite.HaskellName
--                (Database.Persist.TH.packPTH "User")))
--            ((Database.Persist.Sqlite.FTTypeCon
--                (Just (Database.Persist.TH.packPTH "Data.Int")))
--               (Database.Persist.TH.packPTH "Int64")))
--   persistFieldDef UserName
--     = ((((((Database.Persist.Sqlite.FieldDef
--               (Database.Persist.Sqlite.HaskellName
--                  (Database.Persist.TH.packPTH "name")))
--              (Database.Persist.Sqlite.DBName
--                 (Database.Persist.TH.packPTH "name")))
--             ((Database.Persist.Sqlite.FTTypeCon Nothing)
--                (Database.Persist.TH.packPTH "String")))
--            Database.Persist.Sqlite.SqlString)
--           [])
--          True)
--         Database.Persist.Sqlite.NoReference
--   persistFieldDef UserFriend
--     = ((((((Database.Persist.Sqlite.FieldDef
--               (Database.Persist.Sqlite.HaskellName
--                  (Database.Persist.TH.packPTH "friend")))
--              (Database.Persist.Sqlite.DBName
--                 (Database.Persist.TH.packPTH "friend")))
--             ((Database.Persist.Sqlite.FTTypeCon Nothing)
--                (Database.Persist.TH.packPTH "UserId")))
--            Database.Persist.Sqlite.SqlInt64)
--           [])
--          True)
--         ((Database.Persist.Sqlite.ForeignRef
--             (Database.Persist.Sqlite.HaskellName
--                (Database.Persist.TH.packPTH "User")))
--            ((Database.Persist.Sqlite.FTTypeCon
--                (Just (Database.Persist.TH.packPTH "Data.Int")))
--               (Database.Persist.TH.packPTH "Int64")))
--   persistFieldDef UserSSN
--     = ((((((Database.Persist.Sqlite.FieldDef
--               (Database.Persist.Sqlite.HaskellName
--                  (Database.Persist.TH.packPTH "sSN")))
--              (Database.Persist.Sqlite.DBName
--                 (Database.Persist.TH.packPTH "s_s_n")))
--             ((Database.Persist.Sqlite.FTTypeCon Nothing)
--                (Database.Persist.TH.packPTH "String")))
--            Database.Persist.Sqlite.SqlString)
--           [])
--          True)
--         Database.Persist.Sqlite.NoReference
--   persistIdField = UserId
--   fieldLens UserId
--     = (Database.Persist.TH.lensPTH Database.Persist.Sqlite.entityKey)
--         (\ (Database.Persist.Sqlite.Entity _ value_a8yB) key_a8yC
--            -> (Database.Persist.Sqlite.Entity key_a8yC) value_a8yB)
--   fieldLens UserName
--     = (Database.Persist.TH.lensPTH
--          (userName . Database.Persist.Sqlite.entityVal))
--         (\ (Database.Persist.Sqlite.Entity key_a8yD value_a8yE) x_a8yF
--            -> (Database.Persist.Sqlite.Entity key_a8yD)
--                 value_a8yE {userName = x_a8yF})
--   fieldLens UserFriend
--     = (Database.Persist.TH.lensPTH
--          (userFriend . Database.Persist.Sqlite.entityVal))
--         (\ (Database.Persist.Sqlite.Entity key_a8yD value_a8yE) x_a8yF
--            -> (Database.Persist.Sqlite.Entity key_a8yD)
--                 value_a8yE {userFriend = x_a8yF})
--   fieldLens UserSSN
--     = (Database.Persist.TH.lensPTH
--          (userSSN . Database.Persist.Sqlite.entityVal))
--         (\ (Database.Persist.Sqlite.Entity key_a8yD value_a8yE) x_a8yF
--            -> (Database.Persist.Sqlite.Entity key_a8yD)
--                 value_a8yE {userSSN = x_a8yF})

{-@ userIdField :: EntityFieldWrapper <{\row viewer -> True}, {\row field -> field == entityKey row}, {\field row -> field == entityKey row}> _ _ @-}
userIdField :: EntityFieldWrapper User (Key User)
userIdField = EntityFieldWrapper UserId

{-@ userNameField :: EntityFieldWrapper <{\row viewer -> entityKey viewer == userFriend (entityVal row)}, {\row field -> field == userName (entityVal row)}, {\field row -> field == userName (entityVal row)}> _ _ @-}
userNameField :: EntityFieldWrapper User String
userNameField = EntityFieldWrapper UserName

{-@ userFriendField :: EntityFieldWrapper <{\row viewer -> entityKey viewer == userFriend (entityVal row)}, {\row field -> field == userFriend (entityVal row)}, {\field row -> field == userFriend (entityVal row)}> _ _ @-}
userFriendField :: EntityFieldWrapper User (Key User)
userFriendField = EntityFieldWrapper UserFriend

{-@ assume userSSNField :: EntityFieldWrapper <{\row viewer -> entityKey viewer == entityKey row}, {\row field -> field == userSSN (entityVal row)}, {\field row -> field == userSSN (entityVal row)}> _ {v:_ | len v == 9} @-}
userSSNField :: EntityFieldWrapper User String
userSSNField = EntityFieldWrapper UserSSN

-- ** TodoItem
{-@
data TodoItem = TodoItem
  { todoItemOwner :: Key User
  , todoItemTask :: {v:_ | len v > 0}
  }
@-}
-- data TodoItem = TodoItem
--   { todoItemOwner :: Key User
--   , todoItemTask :: String
--   } deriving (Eq, Show)

-- mkPersist sqlSettings [persistLowerCase|
-- TodoItem
--   owner UserId
--   task String
-- |]

-- instance PersistEntity TodoItem where
--   newtype Key TodoItem = TodoItemKey Int
--     deriving (PersistField, ToJSON, FromJSON, Show, Read, Eq, Ord)

--   data EntityField TodoItem typ where
--     TodoItemId :: EntityField TodoItem (Key TodoItem)
--     TodoItemOwner :: EntityField TodoItem (Key User)
--     TodoItemTask :: EntityField TodoItem String

--   data Unique TodoItem

--   keyToValues = undefined
--   keyFromValues = undefined
--   persistIdField = TodoItemId

{-@ todoItemIdField :: EntityFieldWrapper <{\row viewer -> True}, {\row field -> field == entityKey row}, {\field row -> field == entityKey row}> _ _ @-}
todoItemIdField :: EntityFieldWrapper TodoItem (Key TodoItem)
todoItemIdField = EntityFieldWrapper TodoItemId

{-@ todoItemOwnerField :: EntityFieldWrapper <{\row viewer -> True}, {\row field -> field == todoItemOwner (entityVal row)}, {\field row -> field == todoItemOwner (entityVal row)}> _ _ @-}
todoItemOwnerField :: EntityFieldWrapper TodoItem (Key User)
todoItemOwnerField = EntityFieldWrapper TodoItemOwner

{-@ assume todoItemTaskField :: EntityFieldWrapper <{\row viewer -> shared (todoItemOwner (entityVal row)) (entityKey viewer)}, {\row field -> field == todoItemTask (entityVal row)}, {\field row -> field == todoItemTask (entityVal row)}> _ {v:_ | len v > 0} @-}
todoItemTaskField :: EntityFieldWrapper TodoItem String
todoItemTaskField = EntityFieldWrapper TodoItemTask

-- ** Share
{-@
measure shared :: Key User -> Key User -> GHC.Types.Bool
@-}

{-@
data Share where
  Share :: Key User -> Key User -> {v: Share | shared (shareFrom v) (shareTo v)}
@-}
{-@ measure shareFrom @-}
{-@ measure shareTo @-}
-- data Share = Share
--   { shareFrom :: Key User
--   , shareTo :: Key User
--   } deriving (Eq, Show)

-- instance PersistEntity Share where
--   newtype Key Share = ShareKey Int
--     deriving (PersistField, ToJSON, FromJSON, Show, Read, Eq, Ord)

--   data EntityField Share typ where
--     ShareId :: EntityField Share (Key Share)
--     ShareFrom :: EntityField Share (Key User)
--     ShareTo :: EntityField Share (Key User)

--   data Unique Share

--   keyToValues = undefined
--   keyFromValues = undefined
--   persistIdField = ShareId

{-@ assume shareIdField :: EntityFieldWrapper <{\row viewer -> True}, {\row field -> field == entityKey row}, {\field row -> field == entityKey row}> {v: Share | shared (shareFrom v) (shareTo v)} _ @-}
shareIdField :: EntityFieldWrapper Share (Key Share)
shareIdField = EntityFieldWrapper ShareId

{-@ assume shareFromField :: EntityFieldWrapper <{\row viewer -> True}, {\row field -> field == shareFrom (entityVal row)}, {\field row -> field == shareFrom (entityVal row)}> {v: Share | shared (shareFrom v) (shareTo v)} _ @-}
shareFromField :: EntityFieldWrapper Share (Key User)
shareFromField = EntityFieldWrapper ShareFrom

{-@ assume shareToField :: EntityFieldWrapper <{\row viewer -> True}, {\row field -> field == shareTo (entityVal row)}, {\field row -> field == shareTo (entityVal row)}> {v: Share | shared (shareFrom v) (shareTo v)} _ @-}
shareToField :: EntityFieldWrapper Share (Key User)
shareToField = EntityFieldWrapper ShareTo

-- * Infrastructure

{-@ data Tagged a <label :: Entity User -> Bool> = Tagged { content :: a } @-}
data Tagged a = Tagged { content :: a }

{-@ data variance Tagged covariant contravariant @-}

{-@ data RefinedFilter record <r :: Entity record -> Bool, q :: Entity record -> Entity User -> Bool> = RefinedFilter (Filter record) @-}
data RefinedFilter record = RefinedFilter (Filter record)

{-@ data variance RefinedFilter covariant covariant contravariant @-}

{-@
(Field.==.) ::
forall <policy :: Entity record -> Entity User -> Bool,
       selector :: Entity record -> typ -> Bool,
       inverseselector :: typ -> Entity record -> Bool,
       fieldfilter :: typ -> Bool,
       filter :: Entity record -> Bool,
       r :: typ -> Bool>.
  { row :: (Entity record), value :: typ<r> |- {field:(typ<selector row>) | field == value} <: typ<fieldfilter> }
  { field :: typ<fieldfilter> |- {v:(Entity <inverseselector field> record) | True} <: {v:(Entity <filter> record) | True} }
  EntityFieldWrapper<policy, selector, inverseselector> record typ -> typ<r> -> RefinedFilter<filter, policy> record
@-}
(==.) :: PersistField typ => EntityFieldWrapper record typ -> typ -> RefinedFilter record
(EntityFieldWrapper field) ==. value = RefinedFilter (field Database.Persist.==. value)

{-@
(Field.<-.) ::
forall <policy :: Entity record -> Entity User -> Bool,
       selector :: Entity record -> typ -> Bool,
       inverseselector :: typ -> Entity record -> Bool,
       fieldfilter :: typ -> Bool,
       filter :: Entity record -> Bool,
       r :: typ -> Bool>.
  { row :: (Entity record), value :: typ<r> |- {field:(typ<selector row>) | field == value} <: typ<fieldfilter> }
  { field :: typ<fieldfilter> |- {v:(Entity <inverseselector field> record) | True} <: {v:(Entity <filter> record) | True} }
  EntityFieldWrapper<policy, selector, inverseselector> record typ -> [typ<r>] -> RefinedFilter<filter, policy> record
@-}
(<-.) :: PersistField typ => EntityFieldWrapper record typ -> [typ] -> RefinedFilter record
(EntityFieldWrapper field) <-. value = RefinedFilter (field Database.Persist.<-. value)

{-@
data FilterList record <q :: Entity record -> Entity User -> Bool, r :: Entity record -> Bool> where
    Empty :: FilterList<{\_ _ -> True}, {\_ -> True}> record
  | Cons :: RefinedFilter<{\_ -> True}, {\_ _ -> False}> record ->
            FilterList<{\_ _ -> False}, {\_ -> True}> record ->
            FilterList<q, r> record
@-}
{-@ data variance FilterList covariant contravariant covariant @-}
data FilterList a = Empty | Cons (RefinedFilter a) (FilterList a)

-- Don't use `Cons` to construct FilterLists: only ever use `?:`. This should be
-- enforced by not exporting `Cons`.

infixr 5 ?:
{-@
(?:) :: forall <r :: Entity record -> Bool, r1 :: Entity record -> Bool, r2 :: Entity record -> Bool,
                q :: Entity record -> Entity User -> Bool, q1 :: Entity record -> Entity User -> Bool, q2 :: Entity record -> Entity User -> Bool>.
  {row1 :: (Entity <r1> record), row2 :: (Entity <r2> record) |- {v:Entity record | v == row1 && v == row2} <: {v:(Entity <r> record) | True}}
  {row :: (Entity <r> record) |- {v:(Entity <q row> User) | True} <: {v:(Entity <q1 row> User) | True}}
  {row :: (Entity <r> record) |- {v:(Entity <q row> User) | True} <: {v:(Entity <q2 row> User) | True}}
  RefinedFilter<r1, q1> record ->
  FilterList<q2, r2> record ->
  FilterList<q, r> record
@-}
(?:) :: RefinedFilter record -> FilterList record -> FilterList record
f ?: fs = f `Cons` fs

{-@
selectList :: forall <q :: Entity record -> Entity User -> Bool, r1 :: Entity record -> Bool, r2 :: Entity record -> Bool, p :: Entity User -> Bool>.
  { row :: record |- {v:(Entity <r1> record) | entityVal v == row} <: {v:(Entity <r2> record) | True} }
  { row :: (Entity <r2> record) |- {v:(Entity <p> User) | True} <: {v:(Entity <q row> User) | True} }
  FilterList<q, r1> record -> ReaderT _ (Tagged<p>) [(Entity <r2> record)]
@-}
selectList :: (PersistQueryRead backend, PersistRecordBackend record backend) => FilterList record -> ReaderT backend Tagged [Entity record]
selectList filters = Database.Persist.selectList (toPersistFilters filters) []
  where
    toPersistFilters Empty = []
    toPersistFilters (RefinedFilter f `Cons` filters) = f:(toPersistFilters filters)

-- TODO: should Tagged/TIO be a monad transformer? Where should it sit in the stack? Maybe a TaggedIO class or something?

{-@
assume projectList :: forall <r1 :: Entity record -> Bool, r2 :: typ -> Bool, policy :: Entity record -> Entity User -> Bool, p :: Entity User -> Bool, selector :: Entity record -> typ -> Bool, inverseselector :: typ -> Entity record -> Bool>.
  { row :: (Entity <r1> record) |- {v:(Entity <p> User) | True} <: {v:(Entity <policy row> User) | True} }
  { row :: (Entity <r1> record) |- typ<selector row> <: typ<r2> }
  EntityFieldWrapper<policy, selector, inverseselector> record typ ->
  [(Entity <r1> record)] ->
  Tagged<p> [typ<r2>]
@-}
projectList :: PersistEntity record => EntityFieldWrapper record typ -> [Entity record] -> Tagged [typ]
projectList (EntityFieldWrapper entityField) entities = Tagged $ map (\x -> getConst $ fieldLens entityField Const x) entities

instance Functor Tagged where
  fmap f (Tagged x) = Tagged (f x)

instance Applicative Tagged where
  pure = Tagged
  -- f (a -> b) -> f a -> f b
  (Tagged f) <*> (Tagged x) = Tagged (f x)

instance Monad Tagged where
  return x = Tagged x
  (Tagged x) >>= f = f x
  (Tagged _) >>  t = t
  fail          = error

{-@ instance Monad Tagged where
     >>= :: forall <p :: Entity User -> Bool, f:: a -> b -> Bool>.
            x:Tagged <p> a
         -> (u:a -> Tagged <p> (b <f u>))
         -> Tagged <p> (b<f (content x)>);
     >>  :: forall <p :: Entity User -> Bool>.
            x:Tagged<{\v -> false}> a
         -> Tagged<p> b
         -> Tagged<p> b;
     return :: a -> Tagged <{\v -> true}> a
  @-}

instance MonadIO Tagged

-- * Client code
{-@ measure Field.id1 :: Key User @-}
{-@ assume id1 :: {v:Key User | v == id1} @-}
id1 :: Key User
id1 = UserKey undefined

{-@ combinatorExample1 :: RefinedFilter<{\row -> userName (entityVal row) == "alice"}, {\row v -> entityKey v == userFriend (entityVal row)}> User @-}
combinatorExample1 :: RefinedFilter User
combinatorExample1 = userNameField ==. "alice"

{-@ exampleList1 :: FilterList<{\_ -> True}, {\_ -> True}> User @-}
exampleList1 :: FilterList User
exampleList1 = Empty

{-@ exampleList2 :: FilterList<{\_ v -> entityKey v == id1}, {\user -> userFriend (entityVal user) == id1}> User @-}
exampleList2 :: FilterList User
exampleList2 = (userFriendField ==. id1) ?: Empty

{-@ exampleList3 :: FilterList<{\_ v -> entityKey v == id1}, {\user -> userFriend (entityVal user) == id1 && userName (entityVal user) == "alice"}> User @-}
exampleList3 :: FilterList User
exampleList3 = userNameField ==. "alice" ?: userFriendField ==. id1 ?: Empty

{-@ exampleList4 :: FilterList<{\_ v -> entityKey v == id1}, {\user -> userFriend (entityVal user) == id1 && userName (entityVal user) == "alice"}> User @-}
exampleList4 :: FilterList User
exampleList4 = userFriendField ==. id1 ?: userNameField ==. "alice" ?: Empty

{-@ exampleList5 :: FilterList<{\row v -> entityKey v == userFriend (entityVal row)}, {\user -> userName (entityVal user) == "alice"}> User @-}
exampleList5 :: FilterList User
exampleList5 = userNameField ==. "alice" ?: Empty

{-@ exampleSelectList1 :: ReaderT _ (Tagged<{\v -> entityKey v == id1}>) [{v : Entity User | userFriend (entityVal v) == id1}] @-}
exampleSelectList1 :: ReaderT SqlBackend Tagged [Entity User]
exampleSelectList1 = selectList filters
  where
    {-@ filters :: FilterList<{\_ v -> entityKey v == id1}, {\v -> userFriend (entityVal v) == id1}> User @-}
    filters = userFriendField ==. id1 ?: Empty

{-@ exampleSelectList2 :: ReaderT _ (Tagged<{\v -> entityKey v == id1}>) [{v : _ | userFriend (entityVal v) == id1 && userName (entityVal v) == "alice"}] @-}
exampleSelectList2 :: ReaderT SqlBackend Tagged [Entity User]
exampleSelectList2 = selectList (userNameField ==. "alice" ?: userFriendField ==. id1 ?: Empty)

{-@ exampleSelectList3 :: ReaderT _ (Tagged<{\v -> False}>) [{v : _ | userName (entityVal v) == "alice"}] @-}
exampleSelectList3 :: ReaderT SqlBackend Tagged [Entity User]
exampleSelectList3 = selectList (userNameField ==. "alice" ?: Empty)

{-@ projectSelect1 :: [{v:_ | userFriend (entityVal v) == id1}] -> ReaderT _ (Tagged<{\_ -> False}>) [{v:_ | len v == 9}] @-}
projectSelect1 :: [Entity User] -> ReaderT SqlBackend Tagged [String]
projectSelect1 users = lift $ projectList userSSNField users

-- | This is fine: user 1 can see both the filtered rows and the name field in
--   each of these rows
{-@ names :: ReaderT _ (Tagged<{\v -> entityKey v == id1}>) [String]
@-}
names :: ReaderT SqlBackend Tagged [String]
names = do
  rows <- selectList (userFriendField ==. id1 ?: Empty)
  lift $ projectList userNameField rows

-- | This is bad: the result of the query is not public
{-@ bad1 :: ReaderT _ (Tagged<{\v -> True}>) [{v: _ | userFriend (entityVal v) == id1}]
@-}
bad1 :: ReaderT SqlBackend Tagged [Entity User]
bad1 = selectList (userFriendField ==. id1 ?: Empty)

-- | This is bad: who knows who else has name "alice" and is not friends with user 1?
{-@ bad2 :: ReaderT _ (Tagged<{\v -> entityKey v == id1}>) [{v: _ | userName (entityVal v) == "alice"}]
@-}
bad2 :: ReaderT SqlBackend Tagged [Entity User]
bad2 = selectList (userNameField ==. "alice" ?: Empty)

-- | This is bad: user 1 can see the filtered rows but not their SSNs
{-@ badSSNs :: ReaderT _ (Tagged<{\v -> entityKey v == id1}>) [{v:_ | len v == 9}]
@-}
badSSNs :: ReaderT SqlBackend Tagged [String]
badSSNs = do
  rows <- selectList (userFriendField ==. id1 ?: Empty)
  lift $ projectList userSSNField rows

{-@
getSharedTasks :: u:_ -> ReaderT _ (Tagged<{\viewer -> entityKey viewer == u}>) [{v:_ | len v > 0}]
@-}
getSharedTasks :: Key User -> ReaderT SqlBackend Tagged [String]
getSharedTasks userKey = do
  shares <- selectList (shareToField ==. userKey ?: Empty)
  sharedFromUsers <- lift $ projectList shareFromField shares
  sharedTodoItems <- selectList (todoItemOwnerField <-. sharedFromUsers ?: Empty)
  lift $ projectList todoItemTaskField sharedTodoItems

{-@
getSharedTasksBad :: _ -> ReaderT _  (Tagged<{\viewer -> True}>) _
@-}
getSharedTasksBad :: Key User -> ReaderT SqlBackend Tagged [String]
getSharedTasksBad userKey = do
  shares <- selectList (shareToField ==. userKey ?: Empty)
  sharedFromUsers <- lift $ projectList shareFromField shares
  sharedTodoItems <- selectList (todoItemOwnerField <-. sharedFromUsers ?: Empty)
  lift $ projectList todoItemTaskField sharedTodoItems
