# Search event for your life!

## Todolist

### API 
http://api.atnd.org/events/  

http://api.atnd.org/  

- [ ] Search  
    - keywords or,and    
    - date  
    - nickname  
    - twitter_id  
    - owner_nickname  
    - owner_twitter_id  
    
- [ ] Regular notification  

## Robot Respond word
- [ ] help  
- [ ] s|search
- [ ] n|nextpage  

## Set words in info.json
- [x] keywords  

## Const words
- today  
- keywords  

## Flow (unsettled)
```  
user     > bot-name s|search  
bot-name > ok... (show syntax)  
user     > bot-name (input the condition that you want to look for)    
bot-name > return results
```
## Syntax
`keyword:hoge|huga keyword:hoge&fuga date:20141109 name:piyo .....`  
- keyword  
    - hoge&fuga  -> `keyword=hoge,fuga`  
    - hoge|fuga  -> `keyword_or=hoge,fuga`  
- date  
    - 20141109   -> `ymd=20141109`  
- name  
    - hoge       -> `nickname=hoge`  
- twitter  
    - hoge       -> `twitter_id=hoge`  
- oname  
    - hoge       -> `owner_nickname=hoge`  
- otwitter  
    - hoge       -> `owner_twitter_id=hoge`  


