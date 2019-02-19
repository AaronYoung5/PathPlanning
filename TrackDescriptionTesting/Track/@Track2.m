classdef Track2 < handle
    properties
        blue,bx,by,bf
        yellow,yx,yy,yf
        ox,oy
        ix,iy
        num
    end
    methods
        function self = Track2(blue_path,yellow_path,numofpoints)
            self.num = numofpoints;
            [self.yellow,self.yx,self.yy,self.yf] = loaddata(yellow_path,numofpoints);
            [self.blue,self.bx,self.by,self.bf] = loaddata(blue_path,numofpoints);
            tic
            if false
                self.createconnections_normalclosest();
            elseif true
                self.createconnections_normalintersection();
            elseif false
                self.createconnections_normalcenterintersection();
            end
            toc
        end
       
        function createconnections_normalclosest(self)
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
            
            x2 = x1 + nx .* d(1:end-1);
            y2 = y1 + ny .* d(1:end-1);
            
            plot([x1;x2],[y1;y2])
            
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
            self.ox = x;
            self.oy = y;
        end
        
        function createconnections_normalintersection(self)
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
            
            x2 = x1 + nx .* 100;
            y2 = y1 + ny .* 100;
            
            x = [];
            y = [];
            bluex = self.bx;
            bluey = self.by;
            
            for i = 1:length(x1)
                [x0,y0] = intersections([x1(i),x2(i)],[y1(i),y2(i)] ...
                    ,bluex , bluey);
                d = sqrt((x1(i)-x0).^2 + (y1(i)-y0).^2);
                x(end+1) = x0(d==min(d));
                y(end+1) = y0(d==min(d));
                
            end
            self.ox = x;
            self.oy = y;
        end
        
        function createconnections_normalcenterintersection(self)
            [~,x,y] = self.centers();
            dsx = diff(x);
            dsy = diff(y);
            ds = sqrt(dsx.^2+dsy.^2);
            Tx = dsx./ds;
            Ty = dsy./ds;
            
            x1 = x(1:end-1);
            y1 = y(1:end-1);
            
            for ii = 1:2
                if ii == 1
                    normals = [-Ty;Tx];
                else
                    normals = [Ty;-Tx];
                end
                [nx,ny] = points2xy(normals);
                
                x2 = x1 + nx .* 100;
                y2 = y1 + ny .* 100;
                
                x = [];
                y = [];
                if ii == 1
                    boundaryx = self.bx;
                    boundaryy = self.by;
                else
                    boundaryx = self.yx;
                    boundaryy = self.yy;
                end
                
                for i = 1:length(x1)
                    [x0,y0] = intersections([x1(i),x2(i)],[y1(i),y2(i)] ...
                        ,boundaryx , boundaryy);
                    d = sqrt((x1(i)-x0).^2 + (y1(i)-y0).^2);
                    
                    if isempty(d)
                        x(end+1) = boundaryx(i);
                        y(end+1) = boundaryy(i);
                    else
                        x(end+1) = x0(d==min(d));
                        y(end+1) = y0(d==min(d));
                    end
                end
                if ii == 1
                    self.ix = x;
                    self.iy = y;
                else
                    self.ox = x;
                    self.oy = y;
                end
            end
        end
        
        function d = distance(self)
            x1 = self.bx; y1 = self.by;
            x2 = self.yx; y2 = self.yy;
            
            d = sqrt((x2-x1).^2 + (y2-y1).^2);
        end
        
        function [points,x,y] = centers(self)
            points = (self.blue + self.yellow)/2;
            [x,y] = points2xy(points);
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
                plot([self.ox;self.yx(1:end-1)],[self.oy;self.yy(1:end-1)], ...
                    '-b', 'LineWidth', 2)
            end
            if false
                plot([self.ox;self.ix],[self.oy;self.ix], ...
                    '-b', 'LineWidth', 2)
            end
        end
    end
end