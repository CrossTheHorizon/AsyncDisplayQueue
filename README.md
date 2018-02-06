# AsyncDisplayQueue
This is a simple Tool to avoid delay in displaying cell of UITableView.
The draft idea is to separate slow UI works into many tasks. Only one task will be comment on one frame, so that no delay will happen.
So I set up a queue, and use CADisplayLink to fire each tasks when vSync happen.

This tool is very easy to use, here is an example,


```
// Set up 10 image view with cornerRadius
for i in 0 ... 10
{
    let imgV = UIImageView()
    imgV.frame = CGRect.init(x: i*70, y: 10, width: 64, height: 64)
    imgV.layer.cornerRadius = 20;
    imgV.layer.masksToBounds = true;
    addSubview(imgV);
    imgList.append(imgV);
}
```
In cellForRowAtindexPath add your updates as tasks. As an example I separate each image View into a task, but you can group them until defer happen.

```
cell.DisplayId! += 1;
for imgView in cell.asyncView!.imgList
{
    imgView.layer.masksToBounds = false
    imgView.image = nil
    AKDisplayQueue.shared.AddTask(holdingView: cell, task: {
        imgView.image = UIImage.init(named: "splashBackground1.jpg");
        imgView.layer.masksToBounds = true
    })
}
```
