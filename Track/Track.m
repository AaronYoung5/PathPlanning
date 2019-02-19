classdef Track < handle
    properties
        blue,bx,by,bf
        yellow,yx,yy,yf
        hx,hy
        num
    end
    methods
        function self = Track(tracknum,numofpoints)
            bluepath = sprintf('blue%s.csv',tracknum);
            yellowpath = sprintf('yellow%s.csv',tracknum);
            self.num = numofpoints;
            [self.yellow,self.yx,self.yy,self.yf] = loaddata(yellowpath,numofpoints);
            [self.blue,self.bx,self.by,self.bf] = loaddata(bluepath,numofpoints);
            tic
            if false
                self.findclosestpoint()
            elseif false
                self.findnormalclosestpoint()
            elseif false
                self.normallineintersection();
            elseif false
                self.fastclosestpoint();
            end
            toc
        end
        function findclosestpoint(self)
            connectedpoints = [];
            offset = 2;
            for i = 1:self.num
                min = vecnorm(self.yellow(:,i) - self.blue(:,i));
                connectedpoints(:,end+1) = self.blue(:,i);
                for j = i-offset:i+offset
                    if j > self.num || j < 1
                        continue;
                    end
                    d = vecnorm(self.yellow(:,i) - self.blue(:,j));
                    if d < min
                        connectedpoints(:,end) = self.blue(:,j);
                        min = d;
                    end
                end
            end
            [self.hx,self.hy] = points2xy(connectedpoints);
        end
        function findnormalclosestpoint(self)
            connectedpoints = [];
            [x,y] = points2xy(self.yellow);
            dsx = diff(x);
            dsy = diff(y);
            ds = sqrt(dsx.^2+dsy.^2);
            Tx = dsx./ds;
            Ty = dsy./ds;
            
            normals = [-Ty;Tx];
            [nx,ny] = points2xy(normals);
            x1 = x(1:end-1);
            y1 = y(1:end-1);
            
            x2 = x1 + nx .* 50;
            y2 = y1 + ny .* 50;
            
            
            
            [self.hx,self.hy] = points2xy(connectedpoints);
        end
        
        function fastclosestpoint(self)
            [x,y] = points2xy(self.yellow);
            dsx = diff(x);
            dsy = diff(y);
            ds = sqrt(dsx.^2+dsy.^2);
            Tx = dsx./ds;
            Ty = dsy./ds;
            
            normals = [-Ty;Tx];
            [nx,ny] = points2xy(normals);
            x1 = x(1:end-1);
            y1 = y(1:end-1);
            
            d = self.distance();
            
            x2 = x1 + nx .* d(end-1);
            y2 = y1 + ny .* d(end-1);
            
            [x1,y1] = points2xy(self.blue);
            x1 = x1(1:end-1);
            y1 = y1(1:end-1);
            
            x = [];
            y = [];
            
            for i = 1:length(x1)
                d = sqrt((x2(i)-x1).^2 + (y2(i)-y1).^2);
                x(1+end) = x1(d==min(d));
                y(1+end) = y1(d==min(d));
            end
            self.hx = x;
            self.hy = y;
        end
        
        function d = distance(self)
            x1 = self.bx; y1 = self.by;
            x2 = self.yx; y2 = self.yy;
            
            d = sqrt((x2-x1).^2 + (y2-y1).^2);
        end
        
        function draw(self)
            plot(self.bx, self.by,'-k^', ...
                'LineWidth', 2, 'MarkerSize', 7.5,'MarkerFaceColor','b');
            plot(self.yx, self.yy,'-k^', ...
                'LineWidth', 2, 'MarkerSize', 7.5,'MarkerFaceColor','y');
            if false
                plot([self.bx;self.yx],[self.by;self.yy], ...
                    '-r', 'LineWidth', 2)
            end
            if true
                plot([self.hx;self.yx(1:end-1)],[self.hy;self.yy(1:end-1)], ...
                    '-b', 'LineWidth', 2)
            end
        end
    end
end