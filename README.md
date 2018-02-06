# AsyncDisplayQueue
This Tool is used to display TableView 
for i in 0 ... 10
{
    let imgV = UIImageView()
    imgV.frame = CGRect.init(x: i*70, y: 10, width: 64, height: 64)
    imgV.layer.cornerRadius = 20;
    imgV.layer.masksToBounds = true;
    addSubview(imgV);
    imgList.append(imgV);
}

let cell = tb1.dequeueReusableCell(withIdentifier: "cellActivitiesIdentifier") as! TableViewCell1;
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
